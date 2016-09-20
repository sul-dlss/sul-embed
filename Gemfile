source 'https://rubygems.org'

# Pinning to < 3.0 due to issue with teaspoon
# https://github.com/modeset/teaspoon/issues/443
gem 'sprockets-rails', '< 3.0'

gem 'rails', '< 5.0'

gem 'rails-api'

gem 'faraday'

gem 'nokogiri'

gem 'dor-rights-auth'

gem 'config'

gem 'therubyracer'

gem 'iso8601' # to parse durations, since ActiveSupport::Duration doesn't get a parse method till rails 5

group :development, :test do
  gem 'rspec-rails', '~> 3.0.0'
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
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'dlss-capistrano'
end

# Use honeybadger for exception handling
gem 'honeybadger'

gem 'uglifier'

gem 'sass-rails'

gem 'filesize'

gem 'bower-rails'

gem 'leaflet-rails'

gem 'sul_styles', '~>0.5.1'

# Use okcomputer to monitor the application
gem 'okcomputer'
# TODO: remove is_it_working after load balancer and nagios are switched to okcomputer mount point
gem 'is_it_working' # for application monitoring
