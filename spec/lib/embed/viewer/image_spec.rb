require 'rails_helper'

describe Embed::Viewer::Image do
  include PURLFixtures
  let(:purl_object) { double('purl_object') }
  let(:request) { double('request') }
  let(:image_viewer) { Embed::Viewer::Image.new(request) }

  describe 'initialize' do
    it 'should be an Embed::Viewer::Image' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(image_viewer).to be_an Embed::Viewer::Image
    end
  end
  describe 'self.supported_types' do
    it 'should return an array of supported types' do
      expect(Embed::Viewer::Image.supported_types).to eq [:image]
    end
  end
  describe 'width' do
    it 'should return a width' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(image_viewer.width).to_not be nil
    end
  end
  describe 'height' do
    it 'should return a height' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(image_viewer.height).to_not be nil
    end
  end
  describe 'image_id' do
    before { stub_purl_response_with_fixture(image_purl) }
    let(:image) { Embed::PURL.new('12345').contents.first.files.first }
    it 'should return an image id' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(image_viewer.image_id(image)).to eq 'Title_of_the_image'
    end
  end
  describe 'iiif_info_url' do
    let(:image) { Embed::PURL.new('12345').contents.first.files.first }
    it 'should return an IIIF info.json URL' do
      stub_purl_response_and_request(image_purl, request)
      expect(image_viewer.iiif_info_url(image)).to eq 'https://stacks.stanford.edu/image/iiif/12345%252FTitle_of_the_image/info.json'
    end
  end
  describe 'body_html' do
    it 'should return image(s) list' do
      expect(request).to receive(:hide_title?).at_least(:once).and_return(false)
      stub_purl_response_and_request(image_purl, request)
      expect(image_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')
      html = Capybara.string(image_viewer.to_html)
      expect(html).to have_css '.sul-embed-image-list'
      expect(html).to have_css '#osd-Title_of_the_image.sul-embed-osd'

      within '.sul-embed-osd-toolbar' do
        expect(html).to have_css '#osd-Title_of_the_image-zoom-in.fa.fa-plus-circle'
        expect(html).to have_css '#osd-Title_of_the_image-zoom-out.fa.fa-minus-circle'
        expect(html).to have_css '#osd-Title_of_the_image-home.fa.fa-rotate'
        expect(html).to have_css '#osd-Title_of_the_image-full-page.fa.fa-expand'
      end
    end
  end
end
