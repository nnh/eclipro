FactoryGirl.define do
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
  factory :co_author, parent: :participation do
    role 'co_author'
    sections [0, 1]
  end
  factory :principal_investigator, parent: :participation do
    role 'principal_investigator'
    sections [0, 1]
  end
end
