require 'rails_helper'

describe Embed::Viewer::File do
  include PURLFixtures
  let(:purl_object) { double('purl_object') }
  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
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
      expect(Embed::Viewer::File.supported_types).to eq [:file]
    end
  end
  describe 'body_height' do
    it 'should default to 400 minus the footer and header height' do
      stub_request(request)
      expect(file_viewer.send(:body_height)).to eq 307
    end
    it 'consumer requested maxheight minus the header/footer height' do
      height_request = Embed::Request.new(url: 'http://purl.stanford.edu/abc123', maxheight: '500')
      stub_request(height_request)
      viewer = Embed::Viewer::File.new(height_request)
      expect(viewer.send(:body_height)).to eq 407
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
      expect(html).to have_css 'a[download]', visible: false, text: '12.35 kB'
    end
    context 'without file size' do
      it 'displays Download as the link text' do
        stub_purl_response_and_request(file_purl_no_size, request)
        expect(file_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')
        html = Capybara.string(file_viewer.to_html)
        expect(html).to have_css 'a[download]', visible: false, text: /Download$/
      end
    end
    context 'with empty file size' do
      it 'displays Download as the link text' do
        stub_purl_response_and_request(file_purl_empty_size, request)
        expect(file_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')
        html = Capybara.string(file_viewer.to_html)
        expect(html).to have_css 'a[download]', visible: false, text: /Download$/
      end
    end
  end
  describe 'file_type_icon' do
    it 'should return default file icon if mimetype is not recognized' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(file_viewer.file_type_icon('application/null')).to eq 'sul-i-file-new-1'
    end
    it 'should return translated file icon for recognized mime type' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(file_viewer.file_type_icon('application/zip')).to eq 'sul-i-file-zipped'
    end
  end
  describe 'embargo/Stanford only' do
    it 'adds a Stanford specific embargo message with links still present' do
      stub_purl_response_and_request(embargoed_stanford_purl, request)
      expect(file_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com')
      html = Capybara.string(file_viewer.body_html)
      expect(html).to have_css('.sul-embed-embargo-message', text: "Access is restricted to Stanford-affiliated patrons until #{(Time.now + 1.month).strftime('%d-%b-%Y')}")
      expect(html).to have_css('.sul-embed-media-heading.sul-embed-stanford-only a[href="https://stacks.stanford.edu/file/druid:12345/Title%20of%20the%20PDF.pdf"]')
    end
  end
  describe 'embargoed to world' do
    it 'adds a generalized embargo message and no links are present' do
      stub_purl_response_and_request(embargoed_purl, request)
      expect(file_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com')
      html = Capybara.string(file_viewer.body_html)
      expect(html).to have_css('.sul-embed-embargo-message', text: "Access is restricted until #{(Time.now + 1.month).strftime('%d-%b-%Y')}")
      expect(html).not_to have_css('a')
    end
    it 'adds a generalized embargo message and no links are present for an edge case ordering issue' do
      stub_purl_response_and_request(embargoed_edge_purl, request)
      expect(file_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com')
      html = Capybara.string(file_viewer.body_html)
      expect(html).to have_css('.sul-embed-embargo-message', text: "Access is restricted until #{(Time.now + 1.month).strftime('%d-%b-%Y')}")
      expect(html).not_to have_css('a')
    end
  end
end
