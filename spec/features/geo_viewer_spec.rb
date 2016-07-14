require 'rails_helper'
include PURLFixtures

describe 'geo viewer public', js: true do
  before do
    stub_purl_response_with_fixture(geo_purl_public)
    visit_iframe_response
  end

  describe 'loading geo viewer' do
    it 'has geo specific attributes' do
      expect(page).to have_css('.sul-embed-geo', count: 1, visible: true)
    end

    it 'shows the map controls' do
      expect(page).to have_css('.leaflet-control-zoom-in', count: 1, visible: true)
      expect(page).to have_css('.leaflet-control-zoom-out', count: 1, visible: true)

      within '.leaflet-control-attribution.leaflet-control' do
        expect(page).to have_content(' OpenStreetMap, Tiles courtesy of ')
      end
    end

    it 'shows the OpenStreetMap tiles' do
      expect(page).to have_css("img[src*='openstreetmap.fr']", minimum: 6)
    end

    it 'shows the wms tiles' do
      expect(page).to have_css("img[src*='stanford.edu']", minimum: 4)
    end

    it 'download toolbar/panel is present with download links' do
      find('button.sul-embed-footer-tool.sul-i-download-3').click
      within '.sul-embed-download-panel' do
        within '.sul-embed-panel-body' do
          expect(page).to have_css 'li', count: 1, text: 'data.zip'
        end
      end
    end
  end
end

describe 'geo viewer restricted', js: true do
  before do
    stub_purl_response_with_fixture(geo_purl_restricted)
    visit_iframe_response
  end
  describe 'loads viewer' do
    it 'shows the bounding box' do
      # This is a hack, but there is no other way (that we know of) to
      # find this svg element on the page.
      # We also need to explicitly wait for the JS to run.
      expect(page).to have_css('.sul-embed-geo', count: 1, visible: true)
      find '.leaflet-overlay-pane'
      expect(Nokogiri::HTML.parse(page.body).css('path').length).to eq 1
    end
  end
end
