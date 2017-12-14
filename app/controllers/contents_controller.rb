class ContentsController < ApplicationController
  load_and_authorize_resource :protocol
  load_and_authorize_resource through: :protocol
  before_action :prepare_page, except: [:history, :compare]

  def update
    @content.update!(content_params)
    redirect_to protocol_content_path(@protocol, @content), notice: @content.saved_changes? ? t('.success') : t('.no_change')
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = t('.lock_error')
    render :show
  rescue
    render :show
  end

  def history
  end

  def compare
    body = @content.versions[params[:index].to_i].changeset[:body]
    @compare = Content.diff(body[0], body[1])
    @compare.gsub!('contenteditable="true"', '')
  end

  def revert
    @content = @content.versions[params[:index].to_i].reify
    @content.update!(lock_version: params[:lock_version])
    redirect_to protocol_content_path(@protocol, @content), notice: t('.success')
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = t('.lock_error')
    render :show
  rescue
    render :show
  end

  def change_status
    if @content.update(content_params)
      redirect_to protocol_content_path(@protocol, @content), notice: t('.success')
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

    def prepare_page
      @contents = @protocol.contents.sort_by { |c| c.no.to_f }
      section = Section.find_by(template_name: @protocol.template_name, no: @content.no)
      @example = section.example
      @instructions = section.instructions
    end
end
