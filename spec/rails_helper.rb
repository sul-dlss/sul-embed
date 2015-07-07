# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'fixtures/purl_fixtures'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, timeout: 60,
                                         js_errors: true
                                   )
end
Capybara.javascript_driver = :poltergeist

Capybara.default_wait_time = 10

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
#ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  #config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!
end

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

def fill_in_default_sandbox_form
  fill_in 'api-endpoint', with: embed_path
  fill_in 'url-scheme', with: 'http://purl.stanford.edu/ab123cd4567'
end

def send_embed_response
  visit_sandbox
  fill_in_default_sandbox_form
  click_button 'Embed'
  expect(page).to have_css('.sul-embed-container')
end
