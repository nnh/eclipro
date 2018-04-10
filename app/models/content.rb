class Content < ApplicationRecord
  class << self
    include HTMLDiff
  end

  belongs_to :protocol
  has_many :comments, dependent: :destroy
  has_many :images, dependent: :destroy

  enum status: %i(status_new in_progress under_review final)

  before_validation :sanitize_body
  before_save :update_status
  after_save :update_protocol_version

  has_paper_trail on: [:update, :destroy], ignore: [:status, :updated_at, :lock_version]

  def status_icon
    case status
      when 'status_new' then 'asterisk'
      when 'in_progress' then 'pencil'
      when 'under_review' then 'eye'
      when 'final' then 'check'
    end
  end

  def replaced_body(language)
    return body if body.empty? || !editable?

    doc = Nokogiri::HTML(body)
    doc.xpath('//img').each do |i|
      if i['src'].include?("assets/#{protocol.template_name.downcase}")
        filename = "#{i['src'].split('/')[-1].split('-')[0]}.png"
        i['src'] = ActionController::Base.helpers.asset_url("#{protocol.template_name.downcase}/#{filename}")
      else
        image_id = i['src'].scan(/\d{1,}/)[-1]
        i['src'] = Image.find(image_id).file.expiring_url(10.minutes.to_i)
      end
    end
    if language == 'en'
      doc.xpath("//div[@class='ja']").remove
    elsif language == 'ja'
      doc.xpath("//div[@class='en']").remove
    end
    doc.at('body').children.to_s
  end

  def has_reviewer?
    protocol.participations.reviewer.pluck(:sections).flatten.include?(no.split('.')[0].to_i)
  end

  def no_zero?
    no == '0'
  end

  private

    def update_status
      self.status = 'in_progress' if status_new? && persisted? && has_changes_to_save?
    end

    def sanitize_body
      self.body = ApplicationController.helpers.sanitize(self.body).gsub(/\R/, '')
    end

    def update_protocol_version
      protocol.versionup! if saved_change_to_body? && in_progress?
    end
end
