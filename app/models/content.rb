class Content < ApplicationRecord
  class << self
    include HTMLDiff
  end

  belongs_to :protocol
  has_many :comments, dependent: :destroy

  enum status: %i(draft in_progress under_review final)

  has_paper_trail on: [:update, :destroy]
end
