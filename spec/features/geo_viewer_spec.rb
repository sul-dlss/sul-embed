require 'rails_helper'

describe 'geo viewer', js: true do
  include PURLFixtures
  before do
    stub_purl_response_with_fixture(geo_purl)
  end
  
  describe 'loading geo viewer' do
    it 'has geo specific attributes' do
      visit_sandbox
      fill_in_default_sandbox_form
      click_button 'Embed'
      expect(page).to have_css('.sul-embed-geo', count: 1, visible: true)
    end
  end
end