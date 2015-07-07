require 'rails_helper'

describe Embed::Viewer::Geo do
  include PURLFixtures
  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:geo_viewer) { Embed::Viewer::Geo.new(request) }

  describe 'self.supported_types' do
    it 'should return an array of supported types' do
      expect(Embed::Viewer::Geo.supported_types).to eq [:geo]
    end
  end

  describe '.default_body_height' do
    it 'returns the default_body_height' do
      stub_request(request)
      expect(geo_viewer.default_body_height).to eq 400
    end
  end

  describe '.body_height' do
    pending
  end

  describe '.body_html' do
    it 'should return geo html body' do
      stub_purl_response_and_request(geo_purl, request)         
      expect(geo_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')

      html = Capybara.string(geo_viewer.to_html)
      # visible false because we display:none the container until we've loaded the CSS.
      expect(html).to have_css '.sul-embed-geo', visible: false
      expect(html).to have_css '#sul-embed-geo-map', visible: false
      expect(html).to have_css('#sul-embed-geo-map[style="height: 400px"]', visible: false)
    end
  end
end