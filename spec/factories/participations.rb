FactoryBot.define do
  factory :participation do
  end
  factory :author, parent: :participation do
    role 'author'
    sections [0, 1]
  end
  factory :reviewer, parent: :participation do
    role 'reviewer'
    sections [0, 1]
  end
  factory :admin, parent: :participation do
    role 'admin'
    sections [0, 1]
  end
end
