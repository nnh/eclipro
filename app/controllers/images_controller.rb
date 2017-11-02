class ImagesController < ApplicationController
  load_and_authorize_resource

  def create
    geometry = Paperclip::Geometry.from_file params[:file]
    image    = Image.create(image_params)

    render json: {
      image: {
        url:    image_url(image),
        height: geometry.height.to_i,
        width:  geometry.width.to_i
      }
    }, layout: false, content_type: "text/html"
  end

  def show
    download_url = @image.file.expiring_url(1.minute)
    open(download_url, 'rb') do |data|
      send_data data.read, filename: @image.file_file_name, type: @image.file_content_type
    end
  end

  private

    def image_params
      params.permit(:file, :alt, :hint)
    end
end
