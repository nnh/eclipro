class Protocol < ApplicationRecord
  has_one :principal_investigator_user, dependent: :destroy
  has_one :principal_investigator, through: :principal_investigator_user, source: :user
  has_many :co_author_users, dependent: :destroy
  has_many :co_authors, through: :co_author_users, source: :user
  has_many :author_users, dependent: :destroy
  has_many :authors, through: :author_users, source: :user
  has_many :reviewer_users, dependent: :destroy
  has_many :reviewers, through: :reviewer_users, source: :user

  enum role: %i(co_author author reviewer)
  enum status: %i(draft under_review authorized)

  validates :title, presence: true
end
