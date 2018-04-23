class Section < ApplicationRecord
  include NoValueModule

  validates :no, uniqueness: { scope: %i[template_name seq] }

  default_scope { order(:no, :seq) }

  class << self
    def template_names
      pluck(:template_name).uniq!
    end

    def parent_items(template_name)
      where(seq: 0, template_name: template_name)
    end
  end
end
