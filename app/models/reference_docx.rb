class ReferenceDocx < ApplicationRecord
  belongs_to :protocol

  has_attached_file :file
  validates_attachment_content_type :file,
                                    content_type: ['application/zip',
                                                   'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
end
