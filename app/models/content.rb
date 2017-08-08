class Content < ApplicationRecord
  belongs_to :protocol
  has_many :comments, dependent: :destroy

  has_paper_trail on: [:update, :destroy]
end
