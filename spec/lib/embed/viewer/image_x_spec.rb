require 'rails_helper'

describe Embed::Viewer::ImageX do
  include PURLFixtures
  let(:request) { Embed::Request.new(url: 'https://purl.stanford.edu/abc123') }
  let(:image_x_viewer) { Embed::Viewer::ImageX.new(request) }

  describe 'initialize' do
    it 'should be an Embed::Viewer::ImageX' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(image_x_viewer).to be_an Embed::Viewer::ImageX
    end
  end
  describe 'self.supported_types' do
    it 'should return an array of supported types' do
      expect(Embed::Viewer::ImageX.supported_types).to eq [:image, :manuscript, :map, :book]
    end
  end
  describe 'self.show_download_count?' do
    it 'should return false' do
      expect(Embed::Viewer::ImageX.show_download_count?).to be_falsey
    end
  end
  describe 'body_html' do
    it 'should return imageX viewer body' do
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

    it 'full download links should have proper target and rel attributes for download links' do
      expect(request).to receive(:hide_title?).at_least(:once).and_return(false)
      stub_purl_response_and_request(image_with_pdf_restricted_purl, request)
      expect(image_x_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')
      html = Capybara.string(image_x_viewer.to_html)
      link = html.find('ul li div.sul-embed-stanford-only a', visible: false, text: 'Download "Yolo" (as pdf)')
      expect(link['target']).to eq '_blank'
      expect(link['rel']).to eq 'noopener noreferrer'
    end
  end

  describe 'private methods' do
    describe '#drag_and_drop_url' do
      it 'links to a PURL with a manifest parameter' do
        url = image_x_viewer.send(:drag_and_drop_url)
        purl = 'https://purl.stanford.edu/abc123'
        expect(url).to match(%r{^#{purl}\?manifest=#{purl}/iiif/manifest\.json$})
      end
    end
  end
end
