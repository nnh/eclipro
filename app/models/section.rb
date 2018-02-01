class Section < ApplicationRecord
  validates :no, uniqueness: { scope: :template_name }

  scope :by_template, ->(template_name) { where(template_name: template_name).sort_by { |s| s.no.to_f } }

  class << self
    def template_names
      all.pluck(:template_name).uniq!
    end

    def parent_items(template_name)
      by_template(template_name).select { |section| section.no.exclude?('.') }
    end
  end

  def no_value
    no.to_i
  end
end
