class Protocol < ApplicationRecord
  serialize :sponsors
  serialize :study_agent

  has_many :participations, dependent: :destroy
  accepts_nested_attributes_for :participations, allow_destroy: true
  has_many :contents, dependent: :destroy
  accepts_nested_attributes_for :contents, allow_destroy: true

  enum status: %i(in_progress finalized)

  validates :template_name, :title, :protocol_number, presence: true

  before_validation :set_finalized_date, :set_content_final, :set_content_in_progress
  before_save :update_version, unless: -> { will_save_change_to_attribute?(:version) || new_record? }

  def my_role(user)
    if admin?(user)
      Participation.roles_i18n['admin']
    elsif author?(user)
      Participation.roles_i18n['author']
    elsif reviewer?(user)
      Participation.roles_i18n['reviewer']
    end
  end

  def admin?(user)
    participations.admin.exists?(user: user)
  end

  def author?(user)
    participations.author.exists?(user: user)
  end

  def reviewer?(user)
    participations.reviewer.exists?(user: user)
  end

  def participant?(user)
    participations.exists?(user: user)
  end

  def updatable_sections(user)
    all_sections = Section.reject_specified_sections(template_name).pluck(:no)
    return all_sections if admin?(user)
    return [] if reviewer?(user)
    select_sections(all_sections, Participation.find_by(protocol: self, user: user).sections)
  end

  def reviewable_sections(user)
    all_sections = Section.reject_specified_sections(template_name).pluck(:no)
    return all_sections if admin?(user)
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
      sections.flatten
    end

    def update_version
      assign_attributes(version: version + 0.001) if has_changes_to_save? && attribute_in_database(:status) != 'finalized'
      assign_attributes(version: (version + 1).floor) if finalized?
    end

    def set_finalized_date
      assign_attributes(finalized_date: Date.today) if finalized?
    end

    def set_content_final
      contents.each(&:final!) if finalized?
    end

    def set_content_in_progress
      contents.each(&:in_progress!) if attribute_in_database(:status) == 'finalized'
    end
end
