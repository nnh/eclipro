class ContentsController < ApplicationController
  before_action :set_content

  def update
    Content.transaction do
      Protocol.transaction do
        @content.update!(content_params)
        protocol = @content.protocol
        protocol.version += 0.001
        protocol.save!
        redirect_to @content.protocol, notice: t('.success')
      end
    end
  rescue
    redirect_to @content.protocol, alert: t('.failure')
  end

  private
    def set_content
      @content = Content.find(params[:id])
    end

    def content_params
      params.require(:content).permit(:body, :status)
    end
end
