require 'rails_helper'

describe Embed::Viewer::ImageX do
  include PURLFixtures
  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
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
  describe 'body_html' do
    it 'should return imageX viewer body' do
      expect(request).to receive(:hide_title?).at_least(:once).and_return(false)
      stub_purl_response_and_request(image_purl, request)
      expect(image_x_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')
      html = Capybara.string(image_x_viewer.to_html)
      # visible false because we display:none the container until we've loaded the CSS.
      expect(html).to have_css '.sul-embed-image-x', visible: false
    end
  end
end
