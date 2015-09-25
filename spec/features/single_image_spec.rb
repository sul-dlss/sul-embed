require 'rails_helper'

describe 'image x viewer', js: true do
  include PURLFixtures
  before do
    stub_purl_response_with_fixture(image_purl)
    visit_sandbox
  end
  describe 'single image' do
    before do
      fill_in_default_sandbox_form('sg052hd9120')
      click_button 'Embed'
    end
    it 'removes functionality' do
      within '.sul-embed-header' do
        expect(page).to_not have_css '[data-sul-view-mode]'
        expect(page).to_not have_css '[data-sul-view-perspective]'
      end
      expect(page).to_not have_css '.sul-embed-image-x-thumb-slider-container'
      expect(page).to_not have_css '.sul-i-arrow-right-8'
      expect(page).to_not have_css '.sul-i-arrow-left-8'
    end
  end
  describe 'multi image viewer (not paged)' do
    before do
      fill_in_default_sandbox_form('fw090jw3474')
      click_button 'Embed'
    end
    it 'adds overview perspective, individuals mode, and left/right controls' do
      within '.sul-embed-header' do
        expect(page).to have_css '[data-sul-view-perspective]'
        expect(page).to have_css '[data-sul-view-mode="individuals"]'
        expect(page).to_not have_css '[data-sul-view-mode="paged"]'
      end
      expect(page).to have_css '.sul-i-arrow-right-8'
      expect(page).to have_css '.sul-i-arrow-left-8'
    end
  end
  describe 'multimage viewer (paged)' do
    before do
      fill_in_default_sandbox_form('cy496ky1984')
      click_button 'Embed'
    end
    it 'adds overview perspective, paged mode, individuals mode, and left/right controls' do
      within '.sul-embed-header' do
        expect(page).to have_css '[data-sul-view-perspective]'
        expect(page).to have_css '[data-sul-view-mode="individuals"]'
        expect(page).to have_css '[data-sul-view-mode="paged"]'
      end
    end
  end
end
