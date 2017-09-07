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
    @contents = @protocol.contents.order(:created_at)
    @examples = Section.select { |s| s.example.present? }
    @instructions = Section.select { |s| s.instructions.present? }
  end

  def new
    @protocol = Protocol.new
  end

  def edit
  end

  def create
    @protocol = Protocol.new(protocol_params)
    @protocol.principal_investigator = current_user

    Section.all.each do |section|
      @protocol.contents << Content.new(protocol: @protocol, no: section.no, title: section.title,
                                        body: section.template, editable: section.editable)
    end

    if @protocol.save
      redirect_to @protocol, notice: t('.success')
    else
      render :new
    end
  end

  def update
    @protocol.assign_attributes(protocol_params)
    if @protocol.changed?
      @protocol.version += 0.001
      if @protocol.save
        redirect_to @protocol, notice: t('.success')
      else
        render :edit
      end
    else
      redirect_to @protocol, flash: { warning: t('.no_change') }
    end
  end

  def destroy
    @protocol.destroy
    redirect_to protocols_url, notice: t('.success')
  end

  def build_team_form
    @protocol = Protocol.find(params[:protocol_id]) if params[:protocol_id].present?
    @users = User.all.reject { |user| user == current_user }
    @sections = Section.parent_items
  end

  def add_team
    @protocol = Protocol.find(params[:protocol_id]) if params[:protocol_id].present?
    @user = User.find(params[:user_id])
    @role = params[:role]
    @index = params[:index]

    if ['co_author', 'author_all', 'reviewer_all'].include?(@role)
      @sections = Section.parent_items.pluck(:no).join(',')
    else
      @sections = params[:sections].join(',')
    end
  end

  def clone
    original = Protocol.find(params[:id])
    @protocol = original.dup
    @protocol.title = "#{original.title} - (COPY)"
    @protocol.short_title = "#{original.short_title} - (COPY)" if original.short_title.present?
  end

  def show_section
    @content = @protocol.contents.find_by(no: params[:section_no])
  end

  def next_section
    sections = Section.sorted_section
    index = sections.index(params[:section_no])
    if index == sections.size - 1
      head :ok
    else
      index += 1
      if sections[index] == 'compliance'
        @content = sections[index]
      else
        @content = @protocol.contents.find_by(no: sections[index])
      end
    end
  end

  def previous_section
    sections = Section.sorted_section
    index = sections.index(params[:section_no])
    if index == 0
      head :ok
    else
      index -= 1
      if sections[index] == 'compliance' ||  sections[index] == 'title'
        @content = sections[index]
      else
        @content = @protocol.contents.find_by(no: sections[index])
      end
    end
  end

  def export
    @contents = @protocol.contents
    render :export, layout: 'export'
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
