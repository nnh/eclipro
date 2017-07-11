class Protocol < ApplicationRecord
  has_one :co_author_user, dependent: :destroy
  has_one :co_author, through: :co_author_user, source: :user
  has_many :author_users, dependent: :destroy
  has_many :authors, through: :author_users, source: :user
  has_many :reviewer_users, dependent: :destroy
  has_many :reviewers, through: :reviewer_users, source: :user

  enum role: %i(co_author author reviewer)
  enum status: %i(draft under_review authorized)
end
