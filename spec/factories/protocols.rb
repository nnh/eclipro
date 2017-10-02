FactoryGirl.define do
  factory :content do
    protocol nil
    no ''
    title ''
    body ''
    editable true
  end

  factory :protocol do |protocol|
    sequence(:title) do |n|
      "Test protocol #{n}"
    end

    after(:create) do |protocol|
      sections = Section.reject_specified_sections('General').sort { |a, b| a.no.to_f <=> b.no.to_f }
      sections.each do |section|
        FactoryGirl.create(:content, protocol: protocol, no: section.no, title: section.title,
                                     body: section.template, editable: section.editable)
      end
    end
  end
end
