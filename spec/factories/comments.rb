FactoryGirl.define do
  factory :comment do
    sequence(:body) do |n|
      "Test comment #{n}"
    end
    user { create(:user) }
  end
end
