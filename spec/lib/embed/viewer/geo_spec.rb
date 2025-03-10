# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Viewer::Geo do
  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:geo_viewer) { described_class.new(request) }
  let(:purl) { build(:purl) }

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
  end

  describe '.external_url' do
    it 'builds the external url based on settings and druid value' do
      expect(geo_viewer.external_url).to eq('https://earthworks.stanford.edu/catalog/stanford-abc123')
    end
  end

  describe '#map_element_options' do
    subject(:options) { geo_viewer.map_element_options }

    context 'with public content' do
      let(:purl) { build(:purl, bounding_box: [['-1.478794', '29.572742'], ['4.234077', '35.000308']], download: 'world') }

      it 'has the required options' do
        expect(options).to include({ style: 'flex: 1', id: 'sul-embed-geo-map',
                                     'data-bounding-box' => '[["-1.478794", "29.572742"], ["4.234077", "35.000308"]]',
                                     'data-wms-url' => 'https://geowebservices.stanford.edu/geoserver/wms/',
                                     'data-layers' => 'druid:abc123' })
      end
    end

    context 'with restricted content' do
      let(:purl) { build(:purl, bounding_box: [['38.298673', '-123.387626'], ['39.399103', '-122.528843']], download: 'stanford') }

      it 'has the required options' do
        expect(options).to include({ style: 'flex: 1', id: 'sul-embed-geo-map',
                                     'data-bounding-box' => '[["38.298673", "-123.387626"], ["39.399103", "-122.528843"]]' })
      end

      it { is_expected.not_to include('data-wms-url') }
    end
  end
end
