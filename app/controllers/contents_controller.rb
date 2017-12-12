class ContentsController < ApplicationController
  load_and_authorize_resource :protocol
  load_and_authorize_resource through: :protocol

  def update
    @content.update!(content_params)
    flash[:notice] = @content.saved_changes? ? t('.success') : t('.no_change')
  rescue ActiveRecord::StaleObjectError
    flash[:alert] = t('.lock_error')
  rescue
    flash[:alert] = t('.failure')
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
    flash[:notice] = t('.success')
  rescue ActiveRecord::StaleObjectError
    flash[:alert] = t('.lock_error')
  rescue
    flash[:alert] = t('.failure')
  end

  def change_status
    if @content.update(content_params)
      flash[:notice] = t('.success')
    else
      flash[:alert] = t('.failure')
    end
  end

  def show
  end

  private

    def content_params
      params.require(:content).permit(:body, :status, :lock_version)
    end
end
