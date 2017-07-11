class CoAuthorUser < ApplicationRecord
  belongs_to :protocol
  belongs_to :user
end
