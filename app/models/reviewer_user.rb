class ReviewerUser < ApplicationRecord
  belongs_to :protocol
  belongs_to :user
end
