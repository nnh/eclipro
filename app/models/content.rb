class Content < ApplicationRecord
  belongs_to :protocol

  has_many :comments, dependent: :destroy
end
