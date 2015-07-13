require 'rails_helper'

describe 'image viewer count header', js: true do
  include PURLFixtures
  it 'should show image count in header' do
    pending(' is pending due to the migration to imageX viewer')
    stub_purl_response_with_fixture(image_purl)
    visit_sandbox
    fill_in_default_sandbox_form
    click_button 'Embed'
    expect(page).to have_css('.sul-embed-item-count', count: 1)
  end
end
