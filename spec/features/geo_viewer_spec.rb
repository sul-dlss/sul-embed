# frozen_string_literal: true

require 'rails_helper'

# NOTE: This test hits the production purl & stacks servers, and CARTO's basemap CDN (via javascript)
RSpec.describe 'geo viewer', :js do
  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
    visit_iframe_response(purl.druid)
  end

  # ogm-viewer components use shadow DOM, so we need to traverse it
  def map_shadow_root
    find('ogm-preview').shadow_root.find('ogm-map').shadow_root
  end

  context 'with public purl' do
    let(:purl) { build(:purl, :geo, druid: 'cz128vq0535') }

    it 'has geo specific attributes' do
      expect(page).to have_css('.sul-embed-geo', count: 1, visible: :visible)
    end

    it 'shows the map controls' do
      expect(map_shadow_root).to have_css('.maplibregl-ctrl-zoom-in', count: 1)
      expect(map_shadow_root).to have_css('.maplibregl-ctrl-zoom-out', count: 1)
      expect(map_shadow_root).to have_css('.maplibregl-ctrl-attrib', text: 'OpenStreetMap contributors', visible: :all)
    end

    it 'download toolbar/panel is present with download links' do
      click_on 'Share & download'
      click_on 'Download'
      within 'dialog' do
        expect(page).to have_link 'Download data.zip'
        expect(page).to have_link 'Download zip of all files'

        expect(page).to have_css('li a[target="_blank"][rel="noopener noreferrer"]', count: 2)
      end
    end
  end

  context 'with restricted purl' do
    let(:purl) { build(:purl, :geo, druid: 'fp756wn9369', download: 'stanford', view: 'stanford') }

    describe 'loads viewer' do
      it 'shows the canvas' do
        expect(page).to have_text('Stanford users: log in to access all available features')
        expect(map_shadow_root).to have_css('canvas', count: 1)
      end
    end
  end

  context 'with an index map' do
    let(:purl) do
      build(:purl, :geo, druid: 'bc576pk4911',
                         contents: [
                           build(:resource, :file, files: [
                                   build(:resource_file, filename: 'data.zip'),
                                   build(:resource_file, filename: 'data_EPSG_4326.zip'),
                                   resource_file
                                 ]),
                           build(:resource, :image)
                         ])
    end
    let(:resource_file) { build(:resource_file, druid: 'bc576pk4911', filename:) }

    context 'when the file has name index_map.geojson' do
      let(:filename) { 'index_map.geojson' }

      it 'lists the geojson' do
        expect(page).to have_css('.sul-embed-geo', count: 1, visible: :visible)
        expect(page).to have_css "[data-index-map=\"https://stacks.stanford.edu/file/bc576pk4911/#{filename}\"]"
        expect(map_shadow_root).to have_css('canvas', count: 1)
      end
    end
  end

  context 'with geojson data' do
    let(:purl) do
      build(:purl, :geo, druid: 'qp917dm2243',
                         contents: [
                           build(:resource, :file, files: [
                                   build(:resource_file, druid: 'qp917dm2243', filename:, mimetype: 'application/geo+json')
                                 ]),
                           build(:resource, :image)
                         ])
    end

    context 'when the file is geojson' do
      let(:filename) { 'Stanford_Temperature_Model_0km.geojson' }

      it 'loads the viewer' do
        expect(page).to have_css('.sul-embed-geo', count: 1, visible: :visible)
        expect(page).to have_css "[data-geo-json=\"https://stacks.stanford.edu/file/qp917dm2243/#{filename}\"]"
        expect(page).to have_css '[data-layer-type="circle"]'
      end
    end
  end

  context 'with pmtiles data' do
    let(:purl) do
      build(:purl, :geo, druid: 'hf224mw4004',
                         contents: [
                           build(:resource, :file, files: [
                                   build(:resource_file, druid: 'hf224mw4004', filename:, mimetype: 'application/vnd.pmtiles')
                                 ]),
                           build(:resource, :image)
                         ])
    end

    context 'when the file is geojson' do
      let(:filename) { '20231116.pmtiles' }

      it 'loads the viewer' do
        expect(page).to have_css('.sul-embed-geo', count: 1, visible: :visible)
        expect(page).to have_css "[data-pmtiles=\"https://stacks.stanford.edu/file/hf224mw4004/#{filename}\"]"
      end
    end
  end
end
