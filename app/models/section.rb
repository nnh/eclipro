class Section < ApplicationRecord
  validates :no, uniqueness: { scope: :template_name }

  def self.template_names
    all.pluck(:template_name).uniq!
  end

  def self.parent_items
    all.reject { |section| section.no.include?('.') }
  end

  def self.sorted_section
    list = Section.all.pluck(:no)
    list.insert(1, 'compliance')
    list.unshift('title')
  end
end
