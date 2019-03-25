source 'https://rubygems.org'
ruby '2.5.3'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'
# Use sqlite3 as the database for Active Record
# gem 'sqlite3'
gem 'pg'
# Use Puma as the app server
gem 'puma'
# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
# gem 'coffee-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'slim-rails'

gem 'active_model_serializers'

gem 'devise'
gem 'devise-i18n'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'enum_help'

gem 'cancancan'

gem 'paper_trail'
gem 'paper_trail-association_tracking'
gem 'htmldiff'
gem 'aws-sdk-s3'
gem 'http-2'
gem 'paperclip'

gem 'deep_cloneable'

gem 'wkhtmltopdf-binary'
gem 'wicked_pdf'
gem 'pandoc-ruby'

gem 'counter_culture'

gem 'webpacker'

gem 'dotenv-rails'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  # gem 'selenium-webdriver'

  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'

  gem 'faker'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen'

  gem 'letter_opener'

  gem 'bullet'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'awesome_print'

  gem 'foreman'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :test do
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'rails-controller-testing'
end

group :production do
  gem 'newrelic_rpm'
  gem 'rollbar'
end
