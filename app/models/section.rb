class Section < ApplicationRecord
  def self.parent_items
    all.reject { |section| section.no.include?('.') }
  end
end
