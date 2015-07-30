require 'rails_helper'

describe 'imageX viewer', js: true do
  include PURLFixtures
  before do
    stub_purl_response_with_fixture(image_purl)
    visit_sandbox
    fill_in_default_sandbox_form('fw090jw3474')
    click_button 'Embed'
  end
  describe 'thumbnail viewer' do
    it 'is open by default' do
      within '.sul-embed-image-x-thumb-slider-container' do
        expect(page).to have_css '.sul-embed-image-x-thumb-slider-open-close', visible: true
        expect(page).to have_css '.sul-embed-image-x-thumb-slider-scroll', visible: true
        expect(page).to have_css '.sul-embed-image-x-thumb-slider', visible: true
        expect(page).to have_css 'img', count: 36
      end
      find('.sul-embed-image-x-thumb-slider-open-close').click
      expect(page).to have_css '.sul-embed-image-x-thumb-slider', visible: false
    end
  end
end
