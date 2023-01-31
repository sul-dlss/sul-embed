# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'geo viewer public', js: true do
  include PurlFixtures

  before do
    stub_purl_response_with_fixture(geo_purl_public)
    visit_iframe_response('cz128vq0535')
  end

  describe 'loading geo viewer' do
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
      find('button.sul-embed-footer-tool.sul-i-download-3').click
      expect(find('.sul-embed-download-panel', visible: :all).find('.sul-embed-panel-body', visible: :all)).to have_css('li', count: 1, text: 'data.zip')
    end

    it 'includes proper attributes for a _blank target on the download links' do
      find('button.sul-embed-footer-tool.sul-i-download-3').click
      expect(find('.sul-embed-download-panel', visible: :all).find('.sul-embed-panel-body', visible: :all)).to have_css('li a[target="_blank"][rel="noopener noreferrer"]', count: 3)
    end

    it 'shows the sidebar with attribute information after map is clicked' do
      page.driver.browser.action.move_to(find(:css, '#sul-embed-geo-map').native).click.perform
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
end

RSpec.describe 'geo viewer restricted', js: true do
  include PurlFixtures

  before do
    stub_purl_response_with_fixture(geo_purl_restricted)
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

RSpec.describe 'geo index map viewer', js: true do
  include PurlFixtures

  before do
    stub_purl_response_with_fixture(geo_purl_index_map)
    visit_iframe_response 'ts545zc6250'
  end

  describe 'loads viewer' do
    it 'shows the geojson' do
      # This is a hack, but there is no other way (that we know of) to
      # find this svg element on the page.
      # We also need to explicitly wait for the JS to run.
      expect(page).to have_css('.sul-embed-geo', count: 1, visible: :visible)
      expect(page).to have_css '[data-index-map="https://stacks.stanford.edu/file/druid:ts545zc6250/index_map.json"]'
      # only count paths within .leaflet-overlay-pane for testing
      # (page.body contains SVG logos we don't care to count)
      find '.leaflet-overlay-pane'
      expect(Nokogiri::HTML.parse(page.body).search('.leaflet-overlay-pane').css('path').length).to eq 480
    end
  end
end
