FactoryBot.define do
  factory :content do
    protocol nil
    no 0
    seq 0
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
      sections = Section.where(template_name: 'General')
      sections.each do |section|
        FactoryBot.create(:content, protocol: protocol, no: section.no, seq: section.seq,
                                    title: section.title, body: section.template, editable: section.editable)
      end
    end
  end
end
