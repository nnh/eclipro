class Content < ApplicationRecord
  class << self
    include HTMLDiff
  end

  belongs_to :protocol
  has_many :comments, dependent: :destroy
  has_many :images, dependent: :destroy

  enum status: %i(status_new in_progress under_review final)

  has_paper_trail on: [:update, :destroy], ignore: [:status, :updated_at, :lock_version]

  def status_icon
    case status
      when 'status_new' then 'asterisk'
      when 'in_progress' then 'pencil'
      when 'under_review' then 'eye'
      when 'final' then 'check'
    end
  end

  def replaced_body
    new_body = body.gsub('contenteditable="true"', '')
    if new_body.include?('<img src=')
      image_tags = new_body.scan(/<img src=.+?\/>/)
      image_tags.each do |image_tag|
        image_id = image_tag.match(/src=".+?"/)[0].scan(/\d/)[-1]
        image_url = Image.find(image_id).file.expiring_url(1.minute)
        new_image_tag = image_tag.gsub(/src=".+?"/, "src=\"#{image_url}\"")
        new_body.gsub!(image_tag, new_image_tag)
      end
    end

    new_body
  end
end
