# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'geo viewer', :js do
  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
    visit_iframe_response('cz128vq0535')
  end

  context 'with public purl' do
    let(:purl) { build(:purl, :geo) }

    it 'has geo specific attributes' do
      expect(page).to have_css('.sul-embed-geo', count: 1, visible: :visible)
    end

    it 'shows the map controls' do
      expect(page).to have_css('.leaflet-control-zoom-in', count: 1, visible: :visible)
      expect(page).to have_css('.leaflet-control-zoom-out', count: 1, visible: :visible)

      within '.leaflet-control-attribution.leaflet-control' do
        expect(page).to have_content(' OpenStreetMap, Tiles courtesy of ')
      end
    end

    it 'shows the OpenStreetMap tiles' do
      expect(page).to have_css("img[src*='openstreetmap.fr']", minimum: 6)
    end

    it 'shows the wms tiles' do
      expect(page).to have_css("img[src*='stanford.edu']", minimum: 4, visible: :all)
    end

    it 'download toolbar/panel is present with download links' do
      find('button#sul-embed-download-panel-toggle').click
      expect(find('.sul-embed-download-panel', visible: :all).find('.sul-embed-panel-body', visible: :all)).to have_css('li', count: 1, text: 'data.zip')
    end

    it 'includes proper attributes for a _blank target on the download links' do
      find('button#sul-embed-download-panel-toggle').click
      expect(find('.sul-embed-download-panel', visible: :all).find('.sul-embed-panel-body', visible: :all)).to have_css('li a[target="_blank"][rel="noopener noreferrer"]', count: 3)
    end

    it 'download all file link is present' do
      expect(page).to have_css('#sul-embed-footer-download-all')
    end

    it 'shows the sidebar with attribute information after map is clicked', skip: 'flappy; see https://github.com/sul-dlss/sul-embed/issues/2141' do
      page.driver.browser.action.move_to(find_by_id('sul-embed-geo-map').native).click.perform
      using_wait_time 20 do
        expect(page).to have_css '.sul-embed-geo-sidebar-header h3', text: 'Features', visible: :all
        expect(page).to have_css '.sul-embed-geo-sidebar-content dt', text: 's_02_id', visible: :all
        expect(page).to have_css '.sul-embed-geo-sidebar-content dd', visible: :all
      end
      find('.sul-embed-geo-sidebar-header i').click
      # use find('body') to force Capybara to load content with find
      expect(find('body')).to have_css('.sul-embed-geo-sidebar-content dt', text: 's_02_id', visible: :all)
    end
  end

  context 'with restricted purl' do
    let(:purl) { build(:purl, :geo, public: false) }

    before do
      visit_iframe_response
    end

    describe 'loads viewer' do
      it 'shows the bounding box' do
        # This is a hack, but there is no other way (that we know of) to
        # find this svg element on the page.
        # We also need to explicitly wait for the JS to run.
        expect(page).to have_css('.sul-embed-geo', count: 1, visible: :visible)
        # only count paths within .leaflet-overlay-pane for testing
        # (page.body contains SVG logos we don't care to count)
        find '.leaflet-overlay-pane'
        expect(Nokogiri::HTML.parse(page.body).search('.leaflet-overlay-pane').css('path').length).to eq 1
      end
    end
  end

  context 'with an index map' do
    let(:purl) do
      build(:purl, :geo, druid: 'ts545zc6250',
                         contents: [
                           build(:resource, :file, files: [
                                   build(:resource_file, filename: 'data.zip'),
                                   build(:resource_file, filename: 'data_EPSG_4326.zip'),
                                   build(:resource_file, druid: 'ts545zc6250', filename:)
                                 ]),
                           build(:resource, :image)
                         ])
    end

    before do
      visit_iframe_response 'ts545zc6250'
    end

    context 'when index_map.json' do
      let(:filename) { 'index_map.json' }

      describe 'loads viewer' do
        it 'shows the geojson' do
          # This is a hack, but there is no other way (that we know of) to
          # find this svg element on the page.
          # We also need to explicitly wait for the JS to run.
          expect(page).to have_css('.sul-embed-geo', count: 1, visible: :visible)
          expect(page).to have_css "[data-index-map=\"https://stacks.stanford.edu/file/druid:ts545zc6250/#{filename}\"]"
          # only count paths within .leaflet-overlay-pane for testing
          # (page.body contains SVG logos we don't care to count)
          find '.leaflet-overlay-pane'
          expect(Nokogiri::HTML.parse(page.body).search('.leaflet-overlay-pane').css('path').length).to eq 480
        end
      end
    end

    context 'when index_map.geojson' do
      let(:filename) { 'index_map.geojson' }

      describe 'loads viewer' do
        it 'lists the geojson' do
          # This is a hack, but there is no other way (that we know of) to
          # find this svg element on the page.
          # We also need to explicitly wait for the JS to run.
          expect(page).to have_css('.sul-embed-geo', count: 1, visible: :visible)
          expect(page).to have_css "[data-index-map=\"https://stacks.stanford.edu/file/druid:ts545zc6250/#{filename}\"]"
        end
      end
    end
  end
end
