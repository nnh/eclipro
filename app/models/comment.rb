class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :content
  counter_culture :content
end
