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
end
