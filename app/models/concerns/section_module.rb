module SectionModule
  extend ActiveSupport::Concern

  included do
    default_scope { order(:no, :seq) }
  end

  module ClassMethods
    def root
      find_by(no: 0)
    end
  end

  def no_seq
    seq.zero? ? no.to_s : [no, seq].join('.')
  end
end
