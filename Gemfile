# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 7.0'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use Puma as the app server
gem 'puma', '~> 5.0' # avoid capybara errors until capybara release; see https://github.com/teamcapybara/capybara/pull/2530

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
gem 'faraday', '~> 2'
gem 'faraday-follow_redirects'

gem 'config'
gem 'dor-rights-auth'
gem 'iso8601' # to parse durations, since ActiveSupport::Duration doesn't get a parse method till rails 5
gem 'nokogiri', '>= 1.7.1'

group :development, :test do
  gem 'capybara'
  gem 'high_voltage'
  gem 'rspec'
  gem 'rspec-rails'

  gem 'selenium-webdriver', '~> 4.2'
  gem 'webdrivers'

  # Linting/Styleguide Enforcement
  gem 'rubocop', '~> 1.0'
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end

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

gem 'filesize'

gem 'leaflet-rails'

gem 'handlebars_assets'

gem 'newrelic_rpm', group: :production

# Use okcomputer to monitor the application
gem 'okcomputer'

gem 'webpacker', '~> 5.x'

gem 'cssbundling-rails', '~> 1.1'
