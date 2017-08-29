class Protocol < ApplicationRecord
  serialize :sponsors
  serialize :study_agent

  has_one :principal_investigator_user, dependent: :destroy
  has_one :principal_investigator, through: :principal_investigator_user, source: :user
  has_many :co_author_users, dependent: :destroy
  has_many :co_authors, -> {distinct}, through: :co_author_users, source: :user
  accepts_nested_attributes_for :co_author_users, allow_destroy: true
  has_many :author_users, dependent: :destroy
  has_many :authors, -> {distinct}, through: :author_users, source: :user
  accepts_nested_attributes_for :author_users, allow_destroy: true
  has_many :reviewer_users, dependent: :destroy
  has_many :reviewers, -> {distinct}, through: :reviewer_users, source: :user
  accepts_nested_attributes_for :reviewer_users, allow_destroy: true
  has_many :contents, dependent: :destroy

  enum status: %i(in_progress final)
  enum role: %i(co_author author_all reviewer_all author reviewer)

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

  def participant?(user)
    co_author?(user) || author?(user) || reviewer?(user) || principal_investigator?(user)
  end

  def updatable_sections(user)
    return Section.parent_items if principal_investigator?(user) || co_author?(user)
    return [] if reviewer?(user)
    AuthorUser.find_by(protocol: protocol, user: user).sections.split(',')
  end

  def reviewable_sections(user)
    return [] unless reviewer?(user)
    ReviewerUser.find_by(protocol: protocol, user: user).sections.split(',')
  end
end
