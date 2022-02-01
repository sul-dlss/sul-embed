# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 6.1'
# Use Puma as the app server
gem 'puma'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
gem 'faraday', '~> 2'

gem 'nokogiri', '>= 1.7.1'

gem 'dor-rights-auth'

gem 'config'
gem 'deprecation'

gem 'iso8601' # to parse durations, since ActiveSupport::Duration doesn't get a parse method till rails 5

group :development, :test do
  gem 'capybara'
  gem 'high_voltage'
  gem 'rspec'
  gem 'rspec-rails'

  gem 'selenium-webdriver', '!= 3.13.0'
  gem 'webdrivers'

  # Have jQuery local for testing
  gem 'jquery-rails'

  # Needed for deploying to dev/test
  gem 'coffee-rails'

  # Linting/Styleguide Enforcement
  gem 'rubocop', '~> 1.0'
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false

  # for debugging
  gem 'pry-byebug'
end

gem 'codeclimate-test-reporter', group: :test, require: false

group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-shared_configs'
  gem 'dlss-capistrano'
end

# Use honeybadger for exception handling
gem 'honeybadger'

gem 'uglifier'

gem 'sassc-rails'

gem 'filesize'

gem 'leaflet-rails'

gem 'sul_styles', '~>0.6'

gem 'handlebars_assets'

gem 'newrelic_rpm', group: :production

# Use okcomputer to monitor the application
gem 'okcomputer'

gem 'webpacker', '~> 5.x'
