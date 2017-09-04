class ProtocolsController < ApplicationController
  before_action :set_protocol, only: [:show, :edit, :update, :destroy, :show_section]
  load_and_authorize_resource

  def index
    if params[:protocol_name_filter].present?
      @protocols = Protocol.where('title like ?', "%#{params[:protocol_name_filter]}%")
    else
      @protocols = Protocol.all
    end
    @protocols = @protocols.includes(:principal_investigator).select { |protocol| can? :read, protocol }
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

    section_no = Section.pluck(:no)
    section_no.each do |no|
      section = Section.find_by(no: no)
      @protocol.contents << Content.new(protocol: @protocol, no: no, title: section.title,
                                        body: section.template, editable: section.editable)
    end

    if @protocol.save
      redirect_to @protocol, notice: t('.success')
    else
      render :new
    end
  end

  def update
    @protocol.version += 0.001

    if @protocol.update(protocol_params)
      redirect_to @protocol, notice: t('.success')
    else
      render :edit
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
