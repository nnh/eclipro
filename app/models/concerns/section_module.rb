module SectionModule
  extend ActiveSupport::Concern

  included do
    default_scope { order(:no, :seq) }
    scope :root, -> { find_by(no: 0) }
  end

  def no_seq
    seq.zero? ? no.to_s : [no, seq].join('.')
  end
end
