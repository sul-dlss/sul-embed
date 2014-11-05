require 'rails_helper'

describe Embed::Viewer::Image do
  include PURLFixtures
  let(:purl_object) { double('purl_object') }
  let(:request) { Embed::Request.new({url: 'http://purl.stanford.edu/abc123'}) }
  let(:image_viewer) { Embed::Viewer::Image.new(request) }

  describe 'initialize' do
    it 'should be an Embed::Viewer::Image' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(image_viewer).to be_an Embed::Viewer::Image
    end
  end
  describe 'self.supported_types' do
    it 'should return an array of supported types' do
      expect(Embed::Viewer::Image.supported_types).to eq [:image, :manuscript, :map, :book]
    end
  end
  describe 'image_id' do
    before { stub_purl_response_with_fixture(image_purl) }
    let(:image) { Embed::PURL.new('12345').contents.first.files.first }
    it 'should return an image id' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(image_viewer.image_id(image)).to eq 'image_001'
    end
  end
  describe 'iiif_image_id' do
    before { stub_purl_response_with_fixture(image_purl) }
    let(:image) { Embed::PURL.new('abc123').contents.first.files.first }
    it 'should return an IIIF image id' do
      expect(image_viewer.iiif_image_id(image)).to eq 'abc123%252Fimage_001'
    end
  end
  describe 'iiif_image_info' do
    before { stub_purl_response_with_fixture(image_purl) }
    let(:contents) { Embed::PURL.new('abc123').contents }

    image_info = [
      {:id=>"abc123%252Fimage_001", :height=>"123", :width=>"321"},
      {:id=>"abc123%252Fimage_002", :height=>"246", :width=>"123"}]

    it 'should return an IIIF image info' do
      expect(image_viewer.iiif_image_info(contents)).to eq image_info
    end
  end
  describe 'iiif_server' do
    it 'should return an IIIF server URL' do
      expect(image_viewer.iiif_server()).to eq 'https://stacks.stanford.edu/image/iiif'
    end
  end
  describe 'body height' do
    it 'should default to 500' do
      expect(image_viewer.send(:body_height)).to eq 500
    end
  end
  describe 'body_html' do
    it 'should return image(s) list' do
      expect(request).to receive(:hide_title?).at_least(:once).and_return(false)
      stub_purl_response_and_request(image_purl, request)
      expect(image_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')
      html = Capybara.string(image_viewer.to_html)
      # visible false because we display:none the container until we've loaded the CSS.
      expect(html).to have_css '.sul-embed-image-list', visible: false
      expect(html).to have_css '.sul-embed-iiif-osd', visible: false

      within '.sul-embed-iiif-osd' do
        expect(html).to have_css '.iov .iov-menu-bar'
        expect(html).to have_css '.iov .iov-list-view'
        expect(html).to have_css '.iov .iov-gallery-view'
        expect(html).to have_css '.iov .iov-horizontal-view'
      end
    end
  end
end
