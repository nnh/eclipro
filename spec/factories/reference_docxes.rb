FactoryBot.define do
  factory :reference_docx do
    file do
      fixture_file_upload(Rails.root.join('spec', 'fixtures', 'reference.docx'),
                          'application/vnd.openxmlformats-officedocument.wordprocessingml.document')
    end
  end
end
