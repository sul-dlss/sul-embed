require 'rails_helper'

describe 'image x viewer', js: true do
  include PURLFixtures
  before do
    stub_purl_response_with_fixture(image_purl)
  end
  describe 'single image' do
    before do
      visit_iframe_response('sg052hd9120')
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
      visit_iframe_response('fw090jw3474')
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
      visit_iframe_response('cy496ky1984')
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
