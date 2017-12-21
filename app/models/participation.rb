class Participation < ApplicationRecord
  belongs_to :user
  belongs_to :protocol

  enum role: %i[author reviewer co_author principal_investigator]

  validates :role, uniqueness: { scope: :protocol_id }, if: -> { principal_investigator? }
  validates :sections, length: { minimum: 1, message: I18n.t('activerecord.errors.select_sections') }

  class << self
    def addable_roles
      %w[author reviewer co_author]
    end
  end
end
