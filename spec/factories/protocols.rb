FactoryBot.define do
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
      sections = Section.by_template('General')
      sections.each do |section|
        FactoryBot.create(:content, protocol: protocol, no: section.no, title: section.title,
                                    body: section.template, editable: section.editable)
      end
    end
  end
end
