# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'fixtures/purl_fixtures'
require 'fixtures/was_seed_thumbs_fixtures'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, timeout: 60)
end
Capybara.javascript_driver = :poltergeist

Capybara.default_max_wait_time = 10

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
# ActiveRecord::Migration.maintain_test_schema!

RSpec.configure(&:infer_spec_type_from_file_location!)

def stub_purl_response_with_fixture(fixture)
  expect_any_instance_of(Embed::PURL).to receive(:response).at_least(:once).and_return(fixture)
end

def stub_purl_response_and_request(fixture, request)
  stub_purl_response_with_fixture(fixture)
  stub_request(request)
end

def stub_request(request)
  expect(request).to receive(:purl_object).and_return(Embed::PURL.new('12345'))
end

def visit_sandbox
  visit page_path(id: 'sandbox')
end

def toggle_download_panel
  page.find('button[data-sul-embed-toggle="sul-embed-download-panel"]', visible: true)
  page.find('[data-sul-embed-toggle="sul-embed-download-panel"]', match: :first).click
end

def toggle_metadata_panel
  page.find('button[data-sul-embed-toggle="sul-embed-metadata-panel"]', visible: true)
  page.find('[data-sul-embed-toggle="sul-embed-metadata-panel"]', match: :first).click
end

def fill_in_default_sandbox_form(druid = 'ab123cd4567')
  fill_in 'api-endpoint', with: embed_path
  fill_in 'url-scheme', with: "http://purl.stanford.edu/#{druid}"
end

def visit_iframe_response(druid = 'ignored', min_files_to_search: nil, hide_search: nil, hide_title: nil, hide_download: nil, fullheight: nil)
  visit iframe_path(
    url: "#{Settings.purl_url}/#{druid}",
    min_files_to_search: min_files_to_search,
    hide_search: hide_search,
    hide_title: hide_title,
    hide_download: hide_download,
    fullheight: fullheight
  )
  expect(page).to have_css('.sul-embed-container')
end

def send_embed_response
  fill_in_default_sandbox_form
  click_button 'Embed'
end
