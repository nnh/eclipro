module NoValueModule
  extend ActiveSupport::Concern

  def no_seq
    seq.zero? ? no.to_s : [no, seq].join('.')
  end
end
