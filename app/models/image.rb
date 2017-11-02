class Image < ActiveRecord::Base
  belongs_to :content

  has_attached_file :file
  validates_attachment_content_type :file, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']
end
