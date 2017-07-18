class Comment < ApplicationRecord
  belongs_to :protocol
  belongs_to :section
  belongs_to :user
end
