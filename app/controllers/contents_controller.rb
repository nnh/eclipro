class ContentsController < ApplicationController
  load_and_authorize_resource :protocol
  load_and_authorize_resource through: :protocol
  before_action :prepare_menu, except: [:history, :compare]

  def update
    @content.update!(content_params)
    redirect_to protocol_content_path(@protocol, @content, anchor: 'sections'),
                notice: @content.saved_changes? ? t('.success') : t('.no_change')
  rescue => ex
    flash.now[:alert] = t('.lock_error') if ex.is_a?(ActiveRecord::StaleObjectError)
    render :show
  end

  def history
    render json: @content, user: current_user
  end

  def compare
    body = @content.versions[params[:index].to_i].changeset[:body]
    compare = Content.diff(body[0], body[1])
    compare.gsub!('contenteditable="true"', '')

    render json: { data: compare }
  end

  def revert
    @content = @content.versions[params[:index].to_i].reify
    @content.update!(lock_version: params[:lock_version])
    redirect_to protocol_content_path(@protocol, @content, anchor: 'sections'), notice: t('.success')
  rescue => ex
    flash.now[:alert] = t('.lock_error') if ex.is_a?(ActiveRecord::StaleObjectError)
    render :show
  end

  def change_status
    if @content.update(content_params)
      redirect_to protocol_content_path(@protocol, @content, anchor: 'sections'), notice: t('.success')
    else
      flash.now[:alert] = t('.failure')
      render :show
    end
  end

  def show
  end

  private

    def content_params
      params.require(:content).permit(:body, :status, :lock_version)
    end

    def prepare_menu
      @contents = ActiveModel::Serializer::CollectionSerializer.new(@protocol.contents, serializer: ContentMenuSerializer,
                                                                    ability: Ability.new(current_user, params))
      section = @protocol.sections.find_by(no: @content.no, seq: @content.seq)
      @example = section.example
      @instructions = section.instructions
    end
end
