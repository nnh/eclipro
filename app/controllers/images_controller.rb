class ImagesController < ApplicationController
  load_and_authorize_resource :protocol
  load_and_authorize_resource :content, through: :protocol
  load_and_authorize_resource through: :content

  def create
    geometry = Paperclip::Geometry.from_file params[:file]
    image = @content.images.create(image_params)

    respond_to do |format|
      format.json do
        render json: {
          image: {
            url:    protocol_content_image_url(@protocol, @content, image),
            height: geometry.height.to_i,
            width:  geometry.width.to_i
          }
        }, layout: false, content_type: 'text/html'
      end
    end
  end

  def show
    download_url = @image.file.expiring_url(10.minutes)
    open(download_url, 'rb') do |data|
      send_data data.read, filename: @image.file_file_name, type: @image.file_content_type
    end
  end

  private

    def image_params
      params.permit(:file, :alt, :hint)
    end
end
