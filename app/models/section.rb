class Section < ApplicationRecord
  validates :no, uniqueness: { scope: :template_name }

  class << self
    def template_names
      all.pluck(:template_name).uniq!
    end

    def parent_items(template_name)
      reject_specified_sections(template_name).select { |section| section.no.exclude?('.') }
    end

    def reject_specified_sections(template_name)
      where(template_name: template_name).where.not(no: ['title', 'compliance']).sort_by { |s| s.no.to_f }
    end
  end

  def no_value
    no.to_i
  end
end
