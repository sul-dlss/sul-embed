require 'rails_helper'

describe 'feature testing of viewers', js: true do
  include PURLFixtures
  describe 'basic functionality' do
    it 'makes purl embed request and embed' do
      stub_purl_response_with_fixture(file_purl)
      visit_iframe_response
      expect(page).to have_css('.sul-embed-container')
      expect(page).to have_css('.sul-embed-header')
      expect(page).to have_css('.sul-embed-header-title')
      expect(page).to have_css('.sul-embed-body')
      expect(page).to have_css('.sul-embed-footer')
    end
    it 'hides the title when requested' do
      stub_purl_response_with_fixture(file_purl)
      visit_iframe_response('abc123', hide_title: true)
      expect(page).to_not have_css('.sul-embed-header-title')
    end
  end
  describe 'file viewer' do
    it 'contains the file list' do
      stub_purl_response_with_fixture(file_purl)
      visit_iframe_response
      expect(page).to have_css('.sul-embed-file-list')
      expect(page).to have_css('.sul-embed-media-list')
      expect(page).to have_css('.sul-embed-media-heading a', text: 'Title of the PDF.pdf')
      expect(page).to have_css('.sul-embed-description', text: 'File1 Label')
      expect(page).to have_css('.sul-embed-download', text: '12.34 kB')
    end
    it 'contains 4 files in file list' do
      stub_purl_response_with_fixture(multi_resource_multi_type_purl)
      visit_iframe_response
      expect(page).to have_css('.sul-embed-count', count: 4)
    end
  end
end
