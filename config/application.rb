require_relative 'boot'

# rails/all will require all sub-frameworks.
# Enable specific sub-frameworks by uncommenting requires below.
# require 'rails/all'
# require "active_record/railtie"
require 'action_controller/railtie'
# require "action_mailer/railtie"
require 'sprockets/railtie'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SulEmbed
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    require 'embed'
  end
end
