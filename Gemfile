# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 8.0.0'

gem 'propshaft'

# Use Puma as the app server
gem 'puma', '~> 6.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
gem 'faraday', '~> 2'
gem 'faraday-follow_redirects'

gem 'config'
gem 'nokogiri', '>= 1.7.1'

group :development, :test do
  gem 'capybara'
  gem 'debug', platforms: %i[mri]
  gem 'druid-tools'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'high_voltage'
  gem 'rspec'
  gem 'rspec-rails'

  gem 'selenium-webdriver', '~> 4.2'

  gem 'webmock', '~> 3.19'

  # Linting/Styleguide Enforcement
  gem 'rubocop', '~> 1.53'
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
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

gem 'newrelic_rpm', group: :production

# Use okcomputer to monitor the application
gem 'okcomputer'

gem 'vite_rails', '3.0.19'

gem 'view_component', '~> 3.10'

gem 'importmap-rails', '~> 2.0'

gem 'stimulus-rails', '~> 1.3'
