# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'fixtures/purl_fixtures'
require 'fixtures/was_time_map_fixtures'
require 'capybara/rails'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'view_component/test_helpers'
require 'view_component/system_test_helpers'

# Capybara 3.40.0 started using the new chrome headless by default:
# https://developer.chrome.com/docs/chromium/new-headless
# Their default selenium_chrome_headless driver definition includes
# --disable-site-isolation-trials. Some embed tests will crash Chrome with
# that option.
Capybara.register_driver :selenium_chrome_headless do |app|
  browser_options = Selenium::WebDriver::Chrome::Options.new
  browser_options.add_argument('--headless=new')
  browser_options.add_argument('--window-size=1920,1080')
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

Capybara.javascript_driver = :selenium_chrome_headless
Capybara.enable_aria_label = true
Capybara.default_max_wait_time = ENV['CI'] ? 30 : 5

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Rails.root.glob('spec/support/**/*.rb').each { |f| require f }

RSpec.configure do |config|
  # Checks for pending migrations before tests are run.
  # If you are not using ActiveRecord, you can remove this line.
  # ActiveRecord::Migration.maintain_test_schema!
  config.infer_spec_type_from_file_location!

  config.include ViewComponent::TestHelpers, type: :component
  config.include ViewComponent::SystemTestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component
  config.include FactoryBot::Syntax::Methods
end

def visit_iframe_response(druid = 'ignored', min_files_to_search: nil, hide_search: nil, hide_title: nil, hide_download: nil)
  visit iframe_path(
    url: "#{Settings.purl_url}/#{druid}",
    min_files_to_search:,
    hide_search:,
    hide_title:,
    hide_download:
  )
  expect(page).to have_css('.sul-embed-container')
end
