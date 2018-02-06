class Participation < ApplicationRecord
  belongs_to :user
  belongs_to :protocol

  enum role: %i[author reviewer admin]

  validates :user_id, uniqueness: { scope: :protocol_id }
  validates :sections, length: { minimum: 1, message: I18n.t('activerecord.errors.select_sections') }
end
