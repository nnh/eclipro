Dir.glob("#{Rails.root}/db/seeds/**/section_*.yml") do |filename|
  puts filename
  File.open(filename) do |yml_file|
    records = YAML.load(yml_file)['sections']
    records.each do |record|
      section = Section.where(no: record['no'], template_name: record['template_name']).first_or_create
      record['template'].gsub!(/\R/, '')
      record['instructions'].gsub!(/\R/, '')
      record['example'].gsub!(/\R/, '')
      section.update_attributes!(record)
    end
  end
end
