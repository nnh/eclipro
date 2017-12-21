class Participation < ApplicationRecord
  belongs_to :user
  belongs_to :protocol

  enum role: %i[author reviewer co_author principal_investigator]

  validates :role, uniqueness: { scope: :protocol_id }, if: -> { principal_investigator? }
end
