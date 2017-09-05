class Section < ApplicationRecord
  def self.parent_items
    all.reject { |section| section.no.include?('.') }
  end

  def self.sorted_section
    list = Section.all.pluck(:no)
    list.insert(1, 'compliance')
    list.unshift('title')
  end
end
