FactoryBot.define do
  factory :section do
    template_name 'Test template name'
    no 0
    sequence(:seq) { |n| n }
    editable true
    title 'Test title'
    template 'Test template'
    instructions 'Test instructions'
    example 'Test example'
  end
end
