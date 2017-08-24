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
    if params[:protocol_id].nil?
      @users = User.all.reject { |user| user == current_user }
    else
      @users = User.all.reject { |user| Protocol.find(params[:protocol_id]).participant?(user) }
    end
    @sections = Section.all.reject { |section| section.no.include?('.') }
  end

  def add_team
    binding.pry
    user = User.find(params[:user_id])
    role = params[:role]
    sections = params[:sections]
    #
    # if role == 'co_author'
    # end

    # if role == 'co_author'
    #   @protocol.co_authors << user
    # elsif role.include?('author')
    #   contents = @protocol.contents.reject { |content| content.no.include?('.') }
    #   contents.each do |content|
    #     content.authors << user if role == 'author_all' || sections.include?(content.no)
    #   end
    # elsif role.include?('reviewer')
    #   contents = @protocol.contents.reject { |content| content.no.include?('.') }
    #   contents.each do |content|
    #     content.reviewers << user if role == 'reviewer_all' || sections.include?(content.no)
    #   end
    # end
    #
    # if @protocol.save
    #   flash[:notice] = t('.success')
    # else
    #   flash[:alert] = t('.failure')
    # end
  end

  private

    def set_protocol
      @protocol = Protocol.find(params[:id]) if params[:id] == 1
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
        co_author_user_attributes: [:id, :protocol_id, :user_id],
        author_users_attributes: [:id, :protocol_id, :user_id],
        reviewer_users_attributes: [:id, :protocol_id, :user_id]
      )
    end
end
