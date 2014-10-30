require 'rails_helper'

describe Embed::Viewer::File do
  include PURLFixtures
  let(:purl_object) { double('purl_object') }
  let(:request) { Embed::Request.new({url: 'http://purl.stanford.edu/abc123'}) }
  let(:file_viewer) { Embed::Viewer::File.new(request) }
  describe 'initialize' do
    it 'should be an Embed::Viewer::File' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(file_viewer).to be_an Embed::Viewer::File
    end
  end
  describe 'self.default_viewer?' do
    it 'should return true' do
      expect(Embed::Viewer::File.default_viewer?).to be_truthy
    end
  end
  describe 'self.supported_types' do
    it 'should return an array of supported types' do
      expect(Embed::Viewer::File.supported_types).to eq [:media]
    end
  end
  describe 'body_height' do
    it 'should default to 400 minus the footer and header height' do
      stub_request(request)
      expect(file_viewer.send(:body_height)).to eq 302
    end
    it 'consumer requested maxheight minus the header/footer height' do
      height_request = Embed::Request.new({url: 'http://purl.stanford.edu/abc123', maxheight: '400'})
      stub_request(height_request)
      viewer = Embed::Viewer::File.new(height_request)
      expect(viewer.send(:body_height)).to eq 300
    end
  end
  describe 'pretty_file_size' do
    it 'should return the correct size' do
      expect(file_viewer.pretty_filesize(123_45)).to eq '12.35 kB'
    end
  end
  describe 'header tools' do
    it 'should include the search in the header tools' do
      stub_request(request)
      expect(file_viewer.send(:header_tools_logic)).to include(:file_search_logic)
    end
  end
  describe 'body_html' do
    it 'should return a table of files' do
      stub_purl_response_and_request(multi_resource_multi_file_purl, request)
      expect(file_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')
      html = Capybara.string(file_viewer.to_html)
      # visible false because we display:none the container until we've loaded the CSS.
      expect(html).to have_css '.sul-embed-file-list', visible: false
    end
  end
  describe 'file_type_icon' do
    it 'should return default file icon if mimetype is not recognized' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(file_viewer.file_type_icon('application/null')).to eq 'fa-file-o'
    end
    it 'should return translated file icon for recognized mime type' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(file_viewer.file_type_icon('application/zip')).to eq 'fa-file-archive-o'
    end
  end
  describe 'embargo/Stanford only' do
    it 'does something' do
      stub_purl_response_and_request(embargoed_purl, request)
      expect(file_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com')
      html = Capybara.string(file_viewer.body_html)
      expect(html).to have_css('a[data-sul-embed-tooltip="true"]')
      expect(html).to have_css("a[title='Available only to Stanford-affiliated patrons until #{(Time.now + 1.month).strftime('%Y-%m-%d')}']")
      expect(html).to have_css('.sul-embed-media-heading.sul-embed-stanford-only')
    end
  end
end
