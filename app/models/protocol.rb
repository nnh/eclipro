class Protocol < ApplicationRecord
  serialize :sponsors
  serialize :study_agent

  has_many :participations, dependent: :destroy
  accepts_nested_attributes_for :participations, allow_destroy: true
  has_many :contents, dependent: :destroy
  accepts_nested_attributes_for :contents, allow_destroy: true

  enum status: %i(in_progress finalized)

  validates :title, presence: true

  before_validation :set_finalized_date
  before_save :update_version, unless: -> { will_save_change_to_attribute?(:version) }

  def my_role(user)
    if co_author?(user)
      I18n.t('activerecord.enum.participation.role.co_author')
    elsif author?(user)
      I18n.t('activerecord.enum.participation.role.author')
    elsif reviewer?(user)
      I18n.t('activerecord.enum.participation.role.reviewer')
    elsif principal_investigator?(user)
      I18n.t('activerecord.enum.participation.role.principal_investigator')
    end
  end

  def co_author?(user)
    participations.co_author.exists?(user: user)
  end

  def author?(user)
    participations.author.exists?(user: user)
  end

  def reviewer?(user)
    participations.reviewer.exists?(user: user)
  end

  def principal_investigator?(user)
    participations.principal_investigator.exists?(user: user)
  end

  def participant?(user)
    participations.exists?(user: user)
  end

  def updatable_sections(user)
    all_sections = Section.reject_specified_sections(template_name).pluck(:no)
    return all_sections if principal_investigator?(user) || co_author?(user)
    return [] if reviewer?(user)
    select_sections(all_sections, Participation.find_by(protocol: self, user: user).sections)
  end

  def reviewable_sections(user)
    all_sections = Section.reject_specified_sections(template_name).pluck(:no)
    return all_sections if principal_investigator?(user)
    return [] unless reviewer?(user)
    select_sections(all_sections, Participation.find_by(protocol: self, user: user).sections)
  end

  def versionup!
    update!(version: version + 0.001)
  end

  private

    def select_sections(all_sections, origin_sections)
      sections = []
      origin_sections.each do |section|
        sections << all_sections.select { |s| s == section.to_s || s.split('.')[0] == section.to_s }
      end
      sections.flatten!
    end

    def update_version
      assign_attributes(version: version + 0.001) if has_changes_to_save? && attribute_in_database(:status) != 'finalized'
      assign_attributes(version: (version + 1).floor) if finalized?
    end

    def set_finalized_date
      assign_attributes(finalized_date: Date.today) if finalized?
    end
end
