class Section < ApplicationRecord
  include SectionModule

  validates :no, uniqueness: { scope: %i[template_name seq] }

  scope :template_names, -> { pluck(:template_name).uniq! }
  scope :parent_items, ->(template_name) { where(seq: 0, template_name: template_name) }
end
