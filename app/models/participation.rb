class Participation < ApplicationRecord
  belongs_to :user
  belongs_to :protocol

  enum role: %i[author reviewer co_author principal_investigator]

  validates :role, uniqueness: { scope: :protocol_id }, if: -> { principal_investigator? }

  def self.team_roles
    %w[co_author author_all reviewer_all author reviewer]
  end
end
