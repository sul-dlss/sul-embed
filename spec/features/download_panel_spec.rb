require 'rails_helper'

describe 'download panel', js: true do
  include PURLFixtures
  let(:request) { Embed::Request.new(url: 'https://purl.stanford.edu/ab123cd4567') }
  describe 'toggle button' do
    before do
      stub_purl_response_with_fixture(image_purl)
      visit_sandbox
      fill_in_default_sandbox_form('fw090jw3474')
      click_button 'Embed'
    end
    it 'should be present after a user clicks the button' do
      expect(page).to have_css('.sul-embed-download-panel', visible: false)
      toggle_download_panel
      expect(page).to have_css('.sul-embed-download-panel', visible: true)
      expect(page).to have_css('.sul-embed-panel-item-label', text: '')
      expect(page).to have_css('.sul-embed-download-list-item', visible: true, count: 6)
    end

    it 'includes the url param that tells stacks to return the object for download' do
      # Wait for the manifest to come back
      expect(page).to have_css '.sul-embed-image-x-thumb-slider-container'
      page.find('[data-sul-embed-toggle="sul-embed-download-panel"]', match: :first).click
      link = page.find('.sul-embed-download-list a.download-link', match: :first)
      expect(link['href']).to match(/\?download=true$/)
    end
  end
  describe 'restricted download to world' do
    before do
      stub_purl_response_with_fixture(stanford_restricted_image_purl)
      visit_sandbox
      fill_in_default_sandbox_form('bb537hc4022')
      click_button 'Embed'
    end
    it 'should show stanford only icon' do
      # Wait for the manifest to come back
      expect(page).to have_css '.sul-embed-image-x-thumb-slider-container'
      toggle_download_panel
      within '.sul-embed-download-list' do
        expect(page).to have_css '.sul-embed-download-list-item a.download-link', text: 'Download Thumbnail'
        expect(page).to_not have_css '.sul-embed-download-list-item.sul-embed-stanford-only a', count: 4
      end
    end
  end
  describe 'stanford only download' do
    before do
      stub_purl_response_with_fixture(stanford_restricted_image_purl)
      visit_sandbox
      fill_in_default_sandbox_form('bb112zx3193')
      click_button 'Embed'
    end
    it 'should show stanford only icon' do
      # Wait for the manifest to come back
      expect(page).to have_css '.sul-embed-image-x-thumb-slider-container'
      toggle_download_panel
      within '.sul-embed-download-list' do
        expect(page).to have_css '.sul-embed-download-list-item a.download-link', text: 'Download Thumbnail'
        expect(page).to have_css '.sul-embed-download-list-item.sul-embed-stanford-only a', count: 4
      end
    end
  end
  describe 'hide download?' do
    before do
      stub_purl_response_with_fixture(image_purl)
      visit_sandbox
      fill_in_default_sandbox_form('oo000oo0000')
    end
    it 'when selected should hide the button' do
      check('Hide download?')
      click_button 'Embed'
      expect(page).to_not have_css('button[data-sul-embed-toggle="sul-embed-download-panel"]')
    end
    it 'when not selected should display the button' do
      click_button 'Embed'
      expect(page).to have_css('button[data-sul-embed-toggle="sul-embed-download-panel"]')
    end
  end

  describe 'download file count shows within download button' do
    it 'has the file count for multiple files in the download panel' do
      stub_purl_response_with_fixture(multi_file_purl)
      visit_sandbox
      fill_in_default_sandbox_form('oo000oo0000')
      click_button 'Embed'
      within '.sul-i-download-3' do
        expect(page).to have_css '.sul-embed-download-count[aria-label="number of downloadable files"]', text: 2
      end
    end
    it 'has the file count for files all object resources in the download panel' do
      stub_purl_response_with_fixture(multi_resource_multi_media_purl)
      visit_sandbox
      fill_in_default_sandbox_form('oo000oo0000')
      click_button 'Embed'
      within '.sul-i-download-3' do
        expect(page).to have_css '.sul-embed-download-count[aria-label="number of downloadable files"]', text: 4
      end
    end
  end
end
