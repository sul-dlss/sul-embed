require 'rails_helper'

describe 'download panel', type: :feature, js: true do
  include PURLFixtures
  let(:request) { Embed::Request.new(url: 'https://purl.stanford.edu/ab123cd4567') }
  it 'not shown for file viewer and leaves correctly formatted filenames alone' do
    stub_purl_response_with_fixture(multi_file_purl)
    visit_iframe_response
    expect(page).to have_css '.sul-embed-body.sul-embed-file'
    expect(page).not_to have_css '.sul-embed-download-panel'
    link = page.find('.sul-embed-media-list a', match: :first)
    expect(link['href']).to eq('https://stacks.stanford.edu/file/druid:ignored/Title_of_the_PDF.pdf') # this file link was good, no encoding needed
  end
  it 'correctly encodes a wonky filename with spaces and a special character' do
    stub_purl_response_with_fixture(wonky_filename_purl)
    visit_iframe_response
    link = page.find('.sul-embed-media-list a', match: :first)
    expect(link['href']).to eq('https://stacks.stanford.edu/file/druid:ignored/%23Title+of+the+PDF.pdf') # this file link had a # and spaces, encoding is needed
  end
  describe 'toggle button' do
    before do
      stub_purl_response_with_fixture(geo_purl_public)
      visit_iframe_response
    end
    skip 'should be present after a user clicks the button' do
      expect(page).to have_css('.sul-embed-download-panel', visible: false)
      toggle_download_panel
      expect(page).to have_css('.sul-embed-download-panel', visible: true)
      expect(page).to have_css('.sul-embed-panel-item-label', text: '')
      expect(page).to have_css('.sul-embed-download-list-item', visible: true, count: 6)
    end
  end
  describe 'hide download?' do
    before do
      stub_purl_response_with_fixture(geo_purl_public)
    end
    it 'when selected should hide the button' do
      visit_iframe_response('abc123', hide_download: true)
      expect(page).to_not have_css('button[data-sul-embed-toggle="sul-embed-download-panel"]')
    end
    it 'when not selected should display the button' do
      visit_iframe_response('abc123')
      expect(page).to have_css('button[data-sul-embed-toggle="sul-embed-download-panel"]')
    end
  end

  describe 'download file count shows within download button' do
    it 'has the file count for multiple media files in the download panel' do
      stub_purl_response_with_fixture(multi_media_purl)
      visit_iframe_response
      expect(page).to have_css '.sul-embed-body.sul-embed-media' # so shows download count
      within '.sul-i-download-3' do
        expect(page).to have_css '.sul-embed-download-count[aria-label="number of downloadable files"]', text: 2
      end
    end
    it 'only counts downloadable files' do
      stub_purl_response_with_fixture(world_restricted_download_purl)
      visit_iframe_response
      expect(page).to have_css '.sul-embed-body.sul-embed-media' # so shows download count
      within '.sul-i-download-3' do
        expect(page).to have_css '.sul-embed-download-count[aria-label="number of downloadable files"]', text: 1
      end
    end
  end
end
