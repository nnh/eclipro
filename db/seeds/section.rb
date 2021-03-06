sanitizer = Rails::Html::WhiteListSanitizer.new

Dir.glob("#{Rails.root}/db/seeds/**/section_*.yml") do |filename|
  File.open(filename) do |yml_file|
    records = YAML.load(yml_file)['sections']
    records.each do |record|
      section = Section.where(no: record['no'], seq: record['seq'], template_name: record['template_name']).first_or_create
      record['template'] = sanitizer.sanitize(record['template']).gsub(/\R/, '')
      record['instructions'] = sanitizer.sanitize(record['instructions']).gsub(/\R/, '')
      record['example'] = sanitizer.sanitize(record['example']).gsub(/\R/, '')
      section.update!(record)
    end
  end
end
