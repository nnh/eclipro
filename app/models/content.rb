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
    return body if body.empty? || !editable?

    x = REXML::Document.new("<div>#{body}</div>")
    x.get_elements('*[@contenteditable]').each { |c| c.attributes.delete('contenteditable') }
    x.get_elements('//img').each do |i|
      image_id = i.attributes['src'].scan(/\d{1,}/)[-1]
      i.attributes['src'] = Image.find(image_id).file.expiring_url(10.minute)
    end
    x.root.children.join
  end
end
