class Protocol < ApplicationRecord
  serialize :sponsors
  serialize :study_agent

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

  def my_role(user)
    if co_author?(user)
      I18n.t('activerecord.enum.protocol.role.co_author')
    elsif author?(user)
      I18n.t('activerecord.enum.protocol.role.author')
    elsif reviewer?(user)
      I18n.t('activerecord.enum.protocol.role.reviewer')
    elsif principal_investigator?(user)
      I18n.t('activerecord.attributes.protocol.principal_investigator')
    end
  end

  def co_author?(user)
    co_author_ids.include?(user.id)
  end

  def author?(user)
    author_ids.include?(user.id)
  end

  def reviewer?(user)
    reviewer_ids.include?(user.id)
  end

  def principal_investigator?(user)
    principal_investigator == user
  end
end
