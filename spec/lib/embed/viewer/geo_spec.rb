# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Viewer::Geo do
  include PurlFixtures
  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:geo_viewer) { described_class.new(request) }

  describe 'self.supported_types' do
    it 'returns an array of supported types' do
      expect(described_class.supported_types).to eq [:geo]
    end
  end

  describe '.external_url' do
    it 'builds the external url based on settings and druid value' do
      stub_purl_request(request)
      expect(geo_viewer.external_url).to eq('https://earthworks.stanford.edu/catalog/stanford-abc123')
    end
  end

  describe '#map_element_options' do
    it 'for public content' do
      stub_purl_xml_response_and_request(geo_purl_public, request)
      expect(geo_viewer.map_element_options).to be_an Hash
      expect(geo_viewer.map_element_options).to include style: 'flex: 1'
      expect(geo_viewer.map_element_options).to include id: 'sul-embed-geo-map'
      expect(geo_viewer.map_element_options).to include 'data-bounding-box' => '[["-1.478794", "29.572742"], ["4.234077", "35.000308"]]'
      expect(geo_viewer.map_element_options).to include 'data-wms-url' => 'https://geowebservices.stanford.edu/geoserver/wms/'
      expect(geo_viewer.map_element_options).to include 'data-layers' => 'druid:12345'
    end

    it 'for restricted content' do
      stub_purl_xml_response_and_request(geo_purl_restricted, request)
      expect(geo_viewer.map_element_options).to be_an Hash
      expect(geo_viewer.map_element_options).to include style: 'flex: 1'
      expect(geo_viewer.map_element_options).to include id: 'sul-embed-geo-map'
      expect(geo_viewer.map_element_options).to include 'data-bounding-box' => '[["38.298673", "-123.387626"], ["39.399103", "-122.528843"]]'
      expect(geo_viewer.map_element_options).not_to include 'data-layers'
      expect(geo_viewer.map_element_options).not_to include 'data-wms-url'
    end
  end
end
