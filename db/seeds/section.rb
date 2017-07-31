File.open("#{Rails.root}/db/seeds/sections.yml") do |yml_file|
  records = YAML.load(yml_file)['sections']
  records.each do |record|
    Section.create(record)
  end
end
