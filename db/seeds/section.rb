Dir.glob("#{Rails.root}/db/seeds/section_*.yml") do |filename|
  puts filename
  File.open(filename) do |yml_file|
    records = YAML.load(yml_file)['sections']
    records.each do |record|
      Section.create(record)
    end
  end
end
