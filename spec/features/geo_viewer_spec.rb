require 'rails_helper'

describe 'geo viewer public', js: true do
  include PURLFixtures

  before do
    stub_purl_response_with_fixture(geo_purl_public)
    visit_iframe_response('cz128vq0535')
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
      expect(page).to have_css("img[src*='stanford.edu']", minimum: 4, visible: false)
    end

    it 'download toolbar/panel is present with download links' do
      find('button.sul-embed-footer-tool.sul-i-download-3').click
      within '.sul-embed-download-panel' do
        within '.sul-embed-panel-body' do
          expect(page).to have_css 'li', count: 1, text: 'data.zip'
        end
      end
    end

    it 'includes proper attributes for a _blank target on the download links' do
      find('button.sul-embed-footer-tool.sul-i-download-3').click
      within '.sul-embed-download-panel' do
        within '.sul-embed-panel-body' do
          expect(page).to have_css('li a[target="_blank"][rel="noopener noreferrer"]', count: 3)
        end
      end
    end

    it 'shows the sidebar with attribute information after map is clicked' do
      page.driver.browser.action.move_to(find(:css, '#sul-embed-geo-map').native, 380, 245).click.perform
      using_wait_time 20 do
        expect(page).to have_css '.sul-embed-geo-sidebar-header h3', text: 'Features', visible: true
        expect(page).to have_css '.sul-embed-geo-sidebar-content dt', text: 's_02_id', visible: true
        expect(page).to have_css '.sul-embed-geo-sidebar-content dd'
      end
      find('.sul-embed-geo-sidebar-header i').click
      expect(page).to have_css '.sul-embed-geo-sidebar-content dt', text: 's_02_id', visible: false
    end
  end
end

describe 'geo viewer restricted', js: true do
  include PURLFixtures

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
