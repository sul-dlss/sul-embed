require 'rails_helper'

describe 'single image viewer', js: true do
  include PURLFixtures
  before do
    stub_purl_response_with_fixture(image_purl)
    visit_sandbox
    fill_in_default_sandbox_form('sg052hd9120')
    click_button 'Embed'
  end
  describe 'special behavior' do
    it 'removes functionality' do
      within '.sul-embed-header' do
        expect(page).to_not have_css '[data-sul-view-mode]'
        expect(page).to_not have_css '[data-sul-view-perspective]'
      end
      expect(page).to_not have_css '.sul-embed-image-x-thumb-slider-container'
    end
  end
end
