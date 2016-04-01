require 'rails_helper'

describe Embed::Viewer::ImageX do
  include PURLFixtures
  let(:request) { Embed::Request.new(url: 'https://purl.stanford.edu/abc123') }
  let(:image_x_viewer) { described_class.new(request) }

  describe 'initialize' do
    it 'is an Embed::Viewer::ImageX' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(image_x_viewer).to be_an described_class
    end
  end
  describe 'self.supported_types' do
    it 'returns an array of supported types' do
      expect(described_class.supported_types).to eq [:image, :manuscript, :map, :book]
    end
  end
  describe 'body_html' do
    it 'returns imageX viewer body' do
      expect(request).to receive(:hide_title?).at_least(:once).and_return(false)
      stub_purl_response_and_request(image_purl, request)
      expect(image_x_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')
      html = Capybara.string(image_x_viewer.to_html)

      # visible false because we display:none the container until we've loaded the CSS.
      expect(html).to have_css '.sul-embed-image-x', visible: false
      expect(html).to have_css('#sul-embed-image-x[data-manifest-url=\'https://purl.stanford.edu/12345/iiif/manifest.json\']', visible: false)
      expect(html).to have_css('.sul-embed-image-x-buttons button[aria-label]', count: 4, visible: false)
      expect(html).to have_css('#sul-embed-image-x[data-world-restriction=false]', visible: false)
    end
    it 'full download should be present' do
      expect(request).to receive(:hide_title?).at_least(:once).and_return(false)
      stub_purl_response_and_request(image_with_pdf_purl, request)
      expect(image_x_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')
      html = Capybara.string(image_x_viewer.to_html)
      expect(html).to have_css '.sul-embed-download-list-full', visible: false
      expect(html).to have_css 'ul li div a', visible: false, text: 'Download "Writings - \'How to  ..." (as pdf) 4.76 MB'
    end
    it 'full download restricted' do
      expect(request).to receive(:hide_title?).at_least(:once).and_return(false)
      stub_purl_response_and_request(image_with_pdf_restricted_purl, request)
      expect(image_x_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')
      html = Capybara.string(image_x_viewer.to_html)
      expect(html).to have_css 'ul li div.sul-embed-stanford-only a', visible: false, text: 'Download "Yolo" (as pdf)'
    end
  end
end
