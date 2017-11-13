class ProtocolsController < ApplicationController
  before_action :set_protocol, except: [:index, :new, :create, :build_team_form, :add_team, :clone]
  load_and_authorize_resource

  def index
    @protocols = Protocol.includes(:principal_investigator)
    if params[:protocol_name_filter].present?
      @protocols = @protocols.where('title like ?', "%#{params[:protocol_name_filter]}%")
    end
    @protocols = @protocols.select { |protocol| can? :read, protocol }
  end

  def show
    @contents = @protocol.contents.sort_by { |c| c.no.to_f }
    @examples = Section.where(template_name: @protocol.template_name).select { |s| s.example.present? }
    @instructions = Section.where(template_name: @protocol.template_name).select { |s| s.instructions.present? }
  end

  def new
    @protocol = Protocol.new
  end

  def edit
  end

  def create
    @protocol = Protocol.new(protocol_params)
    @protocol.principal_investigator = current_user

    if @protocol.contents.empty?
      sections = Section.reject_specified_sections(@protocol.template_name).sort_by { |c| c.no.to_f }
      sections.each do |section|
        @protocol.contents << Content.new(protocol: @protocol, no: section.no, title: section.title,
                                          body: section.template, editable: section.editable)
      end
    end

    if @protocol.save
      redirect_to @protocol, notice: t('.success')
    else
      render :new
    end
  end

  def update
    Protocol.transaction do
      @protocol.assign_attributes(protocol_params)
      if @protocol.has_changes_to_save?
        @protocol.versionup!
        redirect_to @protocol, notice: t('.success')
      else
        redirect_to @protocol, notice: t('.no_change')
      end
    end
  rescue ActiveRecord::StaleObjectError => e
    redirect_to @protocol, alert: t('.lock_error')
  rescue => e
    redirect_to @protocol, alert: t('.failure')
  end

  def destroy
    @protocol.destroy
    redirect_to protocols_url, notice: t('.success')
  end

  def build_team_form
    @protocol = Protocol.find(params[:protocol_id]) if params[:protocol_id].present?
    @users = User.all.reject { |user| user == current_user }
    @template_name = params[:template_name]
    @sections = Section.parent_items(@template_name)
  end

  def add_team
    @protocol = Protocol.find(params[:protocol_id]) if params[:protocol_id].present?
    @user = User.find(params[:user_id])
    @role = params[:role]
    @index = params[:index]

    if ['co_author', 'author_all', 'reviewer_all'].include?(@role)
      @sections = Section.parent_items(params[:template_name]).pluck(:no).join(',')
    else
      @sections = params[:sections].join(',')
    end
  end

  def clone
    original = Protocol.find(params[:id])
    @protocol = original.deep_clone(include: [:co_author_users, :author_users, :reviewer_users, :contents],
                                    expect: [{ co_author_users: [:id] }, { author_users: [:id] },
                                             { reviewer_users: [:id] }, { contents: [:id, :status, :lock_version] }])
    @protocol.title = "#{original.title} - (COPY)"
    @protocol.short_title = "#{original.short_title} - (COPY)" if original.short_title.present?
  end

  def export
    @section_0 = @protocol.contents.find_by(no: '0')
    @contents = @protocol.contents.where.not(no: '0').sort_by { |c| c.no.to_f }
    @sections = Section.reject_specified_sections(@protocol.template_name)
    render pdf: 'export',
           encording: 'UTF-8',
           layout: 'export.html',
           template: 'protocols/export',
           footer: {
             center: '[page] / [topage]',
             font_size: 9
           },
           viewport_size: '1280x1024',
           show_as_html: params[:debug].present?
  end

  def finalize
    @protocol.status = 'finalized'
    @protocol.version = (@protocol.version + 1).floor
    @protocol.finalized_date = Date.today

    if @protocol.save
      redirect_to protocols_path, notice: t('.success')
    else
      redirect_to protocols_path, notice: t('.failure')
    end
  end

  def reinstate
    @protocol.status = 'in_progress'

    if @protocol.save
      redirect_to protocols_path, notice: t('.success')
    else
      redirect_to protocols_path, notice: t('.failure')
    end
  end

  private

    def set_protocol
      @protocol = Protocol.find(params[:id])
    end

    def protocol_params
      params.require(:protocol).permit(
        :lock_version,
        :template_name,
        :title,
        :short_title,
        :protocol_number,
        :nct_number,
        :sponsor_other,
        :entity_funding_name,
        :has_ide,
        :has_ind,
        :compliance,
        sponsors: [],
        study_agent: [],
        co_author_users_attributes: [:id, :protocol_id, :user_id, :_destroy],
        author_users_attributes: [:id, :protocol_id, :user_id, :sections, :_destroy],
        reviewer_users_attributes: [:id, :protocol_id, :user_id, :sections, :_destroy]
      )
    end
end
