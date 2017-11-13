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
  accepts_nested_attributes_for :contents, allow_destroy: true

  enum status: %i(in_progress finalized)
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
    all_sections = Section.reject_specified_sections(template_name).pluck(:no)
    return all_sections if principal_investigator?(user) || co_author?(user)
    return [] if reviewer?(user)
    select_sections(all_sections, AuthorUser.find_by(protocol: self, user: user).sections.split(','))
  end

  def reviewable_sections(user)
    all_sections = Section.reject_specified_sections(template_name).pluck(:no)
    return all_sections if principal_investigator?(user)
    return [] unless reviewer?(user)
    select_sections(all_sections, ReviewerUser.find_by(protocol: self, user: user).sections.split(','))
  end

  def has_reviewer?
    reviewer_ids.size > 0
  end

  def versionup!
    update!(version: version + 0.001)
  end

  private
    def select_sections(all_sections, origin_sections)
      sections = []
      origin_sections.each do |section|
        sections << all_sections.select { |s| s == section || s.split('.')[0] == section }
      end
      sections.flatten!
    end
end
