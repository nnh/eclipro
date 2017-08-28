class ProtocolsController < ApplicationController
  before_action :set_protocol, only: [:show, :edit, :update, :destroy]

  def index
    # TODO: 権限
    @protocols = Protocol.all
  end

  def show
    @contents = @protocol.contents.order(:created_at)
    @examples = Section.select { |s| s.example.present? }
    @instructions = Section.select { |s| s.instructions.present? }
  end

  def new
    @protocol = Protocol.new
    @contents = @protocol.contents
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

    set_sections_authority

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
    if params[:protocol_id].present?
      @users = User.all.reject { |user| Protocol.find(params[:protocol_id]).participant?(user) }
    else
      @users = User.all.reject { |user| user == current_user }
    end
    @users = @users.reject { |user| params[:added_user_ids]&.include?(user.id.to_s) }
    @sections = Section.all.reject { |section| section.no.include?('.') }
    @index = params[:added_users_count].to_i
  end

  def add_team
    @user = User.find(params[:user_id])
    @role = params[:role]
    @index = params[:index]

    if ['co_author', 'author_all', 'reviewer_all'].include?(@role)
      @sections = Section.all.reject { |section| section.no.include?('.') }.pluck(:no).join(',')
    else
      @sections = params[:sections].join(',')
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
        co_author_users_attributes: [:id, :protocol_id, :user_id, :_destroy]
      )
    end

    def set_sections_authority
      if protocol_params[:co_author_user_attributes].present?
        protocol_params[:co_author_users_attributes].each do |key, value|
          next if value[:_destroy].present?
          user = User.find(value[:user_id])
          @protocol.contents.each do |content|
            content.authors << user
          end
        end
      end

      if params[:protocol][:author_users_attributes].present?
        params[:protocol][:author_users_attributes].each do |key, value|
          next if value[:_destroy].present?
          user = User.find(value[:user_id])
          @protocol.contents.each do |content|
            content.authors << user if value[:sections].split(',').include?(content.no)
          end
        end
      end

      if params[:protocol][:reviewer_users_attributes].present?
        params[:protocol][:reviewer_users_attributes].each do |key, value|
          next if value[:_destroy].present?
          user = User.find(value[:user_id])
          @protocol.contents.each do |content|
            content.reviewers << user if value[:sections].split(',').include?(content.no)
          end
        end
      end
    end
end
