class ReferenceDocxesController < ApplicationController
  load_and_authorize_resource :protocol
  load_and_authorize_resource through: :protocol, singleton: true

  def create
    if @reference_docx.save
      redirect_to @protocol, notice: t('.success')
    else
      redirect_to @protocol, alert: @reference_docx.errors.full_messages.join(', ')
    end
  end

  def show
    download_url = @reference_docx.file.expiring_url(10.minutes)
    open(download_url, 'rb') do |data|
      send_data data.read, filename: @reference_docx.file_file_name, type: @reference_docx.file_content_type
    end
  end

  def update
    if @reference_docx.update(reference_docx_params)
      redirect_to @protocol, notice: t('.success')
    else
      redirect_to @protocol, alert: @reference_docx.errors.full_messages.join(', ')
    end
  end

  def destroy
    @reference_docx.destroy
    redirect_to @protocol, notice: t('.success')
  end

  private

    def reference_docx_params
      params.require(:reference_docx).permit(:file)
    end
end
