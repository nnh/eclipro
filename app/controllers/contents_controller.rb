class ContentsController < ApplicationController
  before_action :set_content, :set_protocol
  load_and_authorize_resource

  def update
    content_params[:body].gsub!(/ style="height: .+px;"/, '')
    content_params[:body].gsub!(/\r/, '')
    Content.transaction do
      Protocol.transaction do
        @content.status = 'in_progress'
        @content.update!(content_params)
        @protocol.version += 0.001
        @protocol.save!
        flash[:notice] = t('.success')
      end
    end
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
    if @content.save
      redirect_to @protocol, notice: t('.success')
    else
      redirect_to @protocol, alert: t('.failure')
    end
  end

  def change_status
    if @content.update(content_params)
      redirect_to @protocol, notice: t('.success')
    else
      redirect_to @protocol, notice: t('.failure')
    end
  end

  private
    def set_content
      @content = Content.find(params[:id])
    end

    def set_protocol
      @protocol = Protocol.find(params[:protocol_id])
    end

    def content_params
      params.require(:content).permit(:body, :status)
    end
end
