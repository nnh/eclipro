class ContentsController < ApplicationController
  before_action :set_content, :set_protocol

  def update
    content_params[:body].gsub!(/ style="height: .+px;"/, '')
    content_params[:body].gsub!(/\r/, '')
    Content.transaction do
      Protocol.transaction do
        @content.update!(content_params)
        @protocol.version += 0.001
        @protocol.save!
        redirect_to @protocol, notice: t('.success')
      end
    end
  rescue
    redirect_to @protocol, alert: t('.failure')
  end

  def history
  end

  def compare
    body = @content.versions[params[:index].to_i].changeset[:body]
    @compare = Content.diff(body[0], body[1])
    @compare.gsub!('contenteditable="true"', '')
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
