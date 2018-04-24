module NoValueModule
  extend ActiveSupport::Concern

  included do
    scope :root, -> { find_by(no: 0) }
  end

  def no_seq
    seq.zero? ? no.to_s : [no, seq].join('.')
  end
end
