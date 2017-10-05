source 'https://rubygems.org'

gem 'rails', '~> 5.1.2'

gem 'faraday'

gem 'nokogiri', '>= 1.7.1'

gem 'dor-rights-auth', '>= 1.3.0' # need downloadable methods

gem 'config'
gem 'deprecation'

gem 'iso8601' # to parse durations, since ActiveSupport::Duration doesn't get a parse method till rails 5

group :development, :test do
  gem 'rspec-rails', '~> 3.5.2' # pinned for https://github.com/rspec/rspec-rails/issues/1800
  gem 'capybara'
  gem 'poltergeist'
  gem 'high_voltage'

  # Coveralls gem for code coverage reporting
  gem 'coveralls', require: false

  # Teaspoon-jasmine is a wrapper for the Jasmine javascript testing library
  gem 'teaspoon-jasmine'

  # Allows jQuery integration into the Jasmine javascript testing framework
  gem 'jasmine-jquery-rails'

  # Have jQuery local for testing
  gem 'jquery-rails'

  # Needed for deploying to dev/test
  gem 'coffee-rails'

  # Linting/Styleguide Enforcement
  gem 'rubocop'

  # guard-rspec for auto-running tests when relevant files are changed
  gem 'guard-rspec', require: false

  # for debugging
  gem 'pry-byebug'
end

gem 'codeclimate-test-reporter', group: :test, require: false

group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  gem 'capistrano-shared_configs'
  gem 'dlss-capistrano'
end

# Use honeybadger for exception handling
gem 'honeybadger'

gem 'uglifier'

gem 'sass-rails'

gem 'filesize'

gem 'bower-rails'

gem 'leaflet-rails'

gem 'sul_styles', '~>0.6'

# Use okcomputer to monitor the application
gem 'okcomputer'
