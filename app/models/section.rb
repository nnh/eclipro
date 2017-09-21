class Section < ApplicationRecord
  validates :no, uniqueness: { scope: :template_name }

  def self.template_names
    all.pluck(:template_name).uniq!
  end

  def self.parent_items(template_name)
    reject_specified_sections(template_name).select { |section| section.no.exclude?('.') }
  end

  def self.sorted_menu(template_name)
    list = reject_specified_sections(template_name).pluck(:no).sort { |a, b| a.to_f <=> b.to_f }
    list.insert(1, 'compliance')
    list.unshift('title')
  end

  def self.reject_specified_sections(template_name)
    where(template_name: template_name).where.not(no: ['title', 'compliance'])
  end
end
