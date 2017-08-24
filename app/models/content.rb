class Content < ApplicationRecord
  class << self
    include HTMLDiff
  end

  belongs_to :protocol
  has_many :comments, dependent: :destroy
  has_many :author_users, dependent: :destroy
  has_many :authors, through: :author_users, source: :user
  has_many :reviewer_users, dependent: :destroy
  has_many :reviewers, through: :reviewer_users, source: :user

  enum status: %i(draft in_progress under_review final)

  has_paper_trail on: [:update, :destroy]

  def author?(user)
    author_ids.include?(user.id)
  end

  def reviewer?(user)
    reviewer_ids.include?(user.id)
  end
end
