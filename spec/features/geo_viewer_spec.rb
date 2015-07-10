require 'rails_helper'

describe 'geo viewer', js: true do
  include PURLFixtures
  before do
    stub_purl_response_with_fixture(geo_purl)
    visit_sandbox
    fill_in_default_sandbox_form
    click_button 'Embed'
  end

  describe 'loading geo viewer' do
    it 'has geo specific attributes' do
      expect(page).to have_css('.sul-embed-geo', count: 1, visible: true)
    end

    it 'shows the map controls' do
      expect(page).to have_css('.leaflet-control-zoom-in', count: 1, visible: true)
      expect(page).to have_css('.leaflet-control-zoom-out', count: 1, visible: true)

      within '.leaflet-control-attribution.leaflet-control' do
        expect(page).to have_content(' contributors, Tiles Courtesy of ')
      end
    end

    it 'shows the Mapquest Tile' do
      expect(page).to have_css("img[src*='mqcdn.com']", minimum: 6)
    end

    it 'shows the bounding box' do
      # This is a hack, but there is no other way (that we know of) to
      # find this svg element on the page.
      # We also need to explicitly wait for the JS to run.
      find ".leaflet-overlay-pane"
      expect(Nokogiri::HTML.parse(page.body).css('path').length).to eq 1
    end

  end
end
