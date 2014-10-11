require 'rails_helper'

describe 'feature testing of viewers', js: true do
  include PURLFixtures
  describe 'basic functionality' do
    it 'should make purl embed request and embed correctly' do
      stub_purl_response_with_fixture(file_purl)
      send_embed_response
      expect(page).to have_css('.sul-embed-container')
      expect(page).to have_css('.sul-embed-header')
      expect(page).to have_css('.sul-embed-body')
      expect(page).to have_css('.sul-embed-footer')
    end
  end
  describe 'file viewer' do
    it 'should contain the file list' do
      stub_purl_response_with_fixture(file_purl)
      send_embed_response
      expect(page).to have_css('.sul-embed-file-list')
      expect(page).to have_css('.sul-embed-media-list')
      expect(page).to have_css('.sul-embed-media-heading a', text: 'Title of the PDF.pdf')
      expect(page).to have_css('.sul-embed-description', text: 'File1 Label')
      expect(page).to have_css('.sul-embed-download', text: '12.06 kiB')
    end
    it 'should contain 2 files in file list' do
      stub_purl_response_with_fixture(multi_resource_multi_file_purl)
      send_embed_response
      expect(page).to have_css('.sul-embed-count', count: 2)
    end
  end
end
