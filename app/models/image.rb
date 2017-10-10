class Image < ActiveRecord::Base
  Paperclip.interpolates :name do |attachment, style|
    sprintf('%05d', attachment.instance.id)
  end

  has_attached_file :file,
                    url: "/upload_images/:name.:extension",
                    path: ":rails_root/public/upload_images/:name.:extension"
  validates_attachment_content_type :file, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']
end
