FactoryBot.define do
  factory :user do
    sequence(:email) do |n|
      "user#{n}@example.com"
    end
    password { 'password' }
    password_confirmation { 'password' }

    name { Faker::Name.name }
    locale { 'en' }
  end
end
