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

  describe '.body_html' do
    it 'should return geo html body for public resources' do
      stub_purl_response_and_request(geo_purl_public, request)
      expect(geo_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')

      html = Capybara.string(geo_viewer.to_html)
      # visible false because we display:none the container until we've loaded the CSS.
      expect(html).to have_css '.sul-embed-geo', visible: false
      expect(html).to have_css '#sul-embed-geo-map', visible: false
      expect(html).to have_css('#sul-embed-geo-map[style="height: 400px"]', visible: false)
      expect(html).to have_css('#sul-embed-geo-map[data-bounding-box=\'[["38.298673", "-123.387626"], ["39.399103", "-122.528843"]]\']', visible: false)
      expect(html).to have_css('#sul-embed-geo-map[data-wms-url="https://geowebservices.stanford.edu/geoserver/wms/"]', visible: false)
      expect(html).to have_css('#sul-embed-geo-map[data-layers="druid:12345"]', visible: false)
    end
  end
  describe '.external_url' do
    it 'should build the external url based on settings and druid value' do
      stub_request(request)
      expect(geo_viewer.external_url).to eq('https://earthworks.stanford.edu/catalog/stanford-abc123')
    end
  end
  describe '#download_html' do
    it 'returns an empty string when hide_download' do
      geo_viewer = Embed::Viewer::Geo.new(
        Embed::Request.new(
          {url: 'http://purl.stanford.edu/abc123', hide_download: 'true'}
        )
      )
      expect(geo_viewer.download_html).to eq ''
    end
    it 'generates a file list when file has resources' do
      stub_purl_response_and_request(geo_purl_public, request)
      html = Capybara.string(geo_viewer.download_html)
      expect(html).to have_css 'li', visible: false, count: 1
      expect(html).to have_css 'a[href="https://stacks.stanford.edu/file/druid:12345/data.zip"]', visible: false
    end
    it 'stanford only resources have the stanford-only class' do
      stub_purl_response_and_request(stanford_restricted_file_purl, request)
      html = Capybara.string(geo_viewer.download_html)
      expect(html).to have_css 'li.sul-embed-stanford-only', visible: false
    end
  end
  describe '#map_element_options' do
    it 'for public content' do
      stub_purl_response_and_request(geo_purl_public, request)
      expect(geo_viewer.map_element_options).to be_an Hash
      expect(geo_viewer.map_element_options).to include style: 'height: 400px'
      expect(geo_viewer.map_element_options).to include id: 'sul-embed-geo-map'
      expect(geo_viewer.map_element_options).to include 'data-bounding-box' => [['38.298673', '-123.387626'], ['39.399103', '-122.528843']]
      expect(geo_viewer.map_element_options).to include 'data-wms-url' => 'https://geowebservices.stanford.edu/geoserver/wms/'
      expect(geo_viewer.map_element_options).to include 'data-layers' => 'druid:12345'
    end

    it 'for restricted content' do
      stub_purl_response_and_request(geo_purl_restricted, request)
      expect(geo_viewer.map_element_options).to be_an Hash
      expect(geo_viewer.map_element_options).to include style: 'height: 400px'
      expect(geo_viewer.map_element_options).to include id: 'sul-embed-geo-map'
      expect(geo_viewer.map_element_options).to include 'data-bounding-box' => [['38.298673', '-123.387626'], ['39.399103', '-122.528843']]
      expect(geo_viewer.map_element_options).to_not include 'data-layers'
      expect(geo_viewer.map_element_options).to_not include 'data-wms-url'
    end
  end
end
