require 'rails_helper'

describe 'image viewer count header' do
  include PURLFixtures
  it 'should show image count in header', js: true do
    stub_purl_response_with_fixture(image_purl)
    visit_sandbox
    fill_in_default_sandbox_form
    click_button 'Embed'
    expect(page).to have_css('.sul-embed-item-count', count: 1)
  end
end
