FactoryGirl.define do
  factory :content do
    protocol nil
    no ''
    title ''
    body ''
    editable true
  end

  factory :protocol do
    sequence(:title) do |n|
      "Test protocol #{n}"
    end

    sequence(:protocol_number) do |n|
      "TP#{n}"
    end

    after(:create) do |protocol|
      sections = Section.reject_specified_sections('General').sort_by { |c| c.no.to_f }
      sections.each do |section|
        FactoryGirl.create(:content, protocol: protocol, no: section.no, title: section.title,
                                     body: section.template, editable: section.editable)
      end
    end
  end
end
