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
        expect(page).to have_css '.sul-embed-thumb-slider-scroll', visible: true
        expect(page).to have_css '.sul-embed-image-x-thumb-slider', visible: true
        expect(page).to have_css 'img', count: 36
      end
      find('.sul-embed-image-x-thumb-slider-open-close').click
      expect(page).to have_css '.sul-embed-image-x-thumb-slider', visible: false
    end
    describe 'is hidden when in overview' do
      before do
        expect(page).to have_css '.sul-embed-image-x-thumb-slider-container', visible: true
        find('[data-sul-view-perspective="overview"]').click
        expect(page).to have_css '.sul-embed-image-x-thumb-slider-container', visible: false
      end
      it 'reappears when canvas clicked' do
        find('[data-id="https://purl.stanford.edu/fw090jw3474/canvas/canvas-2"]').click
        expect(page).to have_css '.sul-embed-image-x-thumb-slider-container', visible: true
      end
      it 'reappears when detail select' do
        find('[data-sul-view-mode="individuals"]').click
        expect(page).to have_css '.sul-embed-image-x-thumb-slider-container', visible: true
      end
    end
    describe 'keyboard controls' do
      it 'navigates left and right' do
        expect(page).to have_css '.active[title="Image 1"]'
        container = find('.sul-embed-container')
        container.native.send_key(:Right)
        expect(page).to have_css '.active[title="Image 2"]'
        container.native.send_key(:Left)
        expect(page).to have_css '.active[title="Image 1"]'
      end
      it 'in overview navigate left/right' do
        expect(page).to have_css '.active[title="Image 1"]'
        find('[data-sul-view-perspective="overview"]').click
        container = find('.sul-embed-container')
        container.native.send_key(:Right)
        expect(page).to have_css '.active[title="Image 2"]'
        container.native.send_key(:Left)
        expect(page).to have_css '.active[title="Image 1"]'
      end
      it 'with closed thumb slider, do not navigate' do
        expect(page).to have_css '.active[title="Image 1"]'
        find('.sul-embed-image-x-thumb-slider-open-close').click
        expect(page).to have_css '.sul-embed-image-x-thumb-slider-container',
                                 visible: false
        container = find('.sul-embed-container')
        container.native.send_key(:Right)
        expect(page).to have_css '.active[title="Image 1"]', visible: false
      end
    end
  end
end
