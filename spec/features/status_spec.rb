# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'application and dependency monitoring' do
  it '/status checks if Rails app is running' do
    visit '/status'
    expect(page.status_code).to eq 200
    expect(page).to have_text('Application is running')
  end

  it '/status/all checks if required dependencies are ok and also shows non-crucial dependencies' do
    visit '/status/all'
    expect(page.status_code).to eq 200
    expect(page).to have_text('HTTP check successful')
    expect(page).to have_text('purl_url')
    expect(page).to have_text('stacks_url')
    expect(page).to have_text('geo_web_services_url') # non-crucial
  end

  it '/status/streaming_url responds if Settings.enable_media_viewer? is true' do
    # set to true in config/settings/test.yml;  config/initializers already loaded at this point
    visit '/status/streaming_url'
    expect(page.status_code).to eq 200
    expect(page).to have_text('streaming_url')
  end
end
