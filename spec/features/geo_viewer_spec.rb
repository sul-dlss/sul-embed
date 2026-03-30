# frozen_string_literal: true

require 'rails_helper'

# NOTE: This test hits the production geowebserivces & stacks servers (via javascript)
RSpec.describe 'geo viewer', :js do
  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
    visit_iframe_response(purl.druid)
  end

  context 'with public purl' do
    let(:purl) { build(:purl, :geo, druid: 'cz128vq0535') }

    it 'has geo specific attributes' do
      expect(page).to have_css('.sul-embed-geo', count: 1, visible: :visible)
    end

    it 'shows the map controls' do
      expect(page).to have_css('.maplibregl-ctrl-zoom-in', count: 1, visible: :visible)
      expect(page).to have_css('.maplibregl-ctrl-zoom-out', count: 1, visible: :visible)

      within '.maplibregl-ctrl-attrib' do
        expect(page).to have_content('OpenStreetMap contributors')
      end
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
    let(:purl) { build(:purl, :geo, druid: 'fp756wn9369', download: 'stanford', view: 'stanford') }

    describe 'loads viewer' do
      it 'shows the canvas' do
        expect(page).to have_text('Stanford users: log in to access all available features')
        expect(page).to have_css('canvas', count: 1, visible: :visible)
      end
    end
  end

  context 'with an index map' do
    let(:purl) do
      build(:purl, :geo, druid: 'mf519gg2738',
                         contents: [
                           build(:resource, :file, files: [
                                   build(:resource_file, filename: 'data.zip'),
                                   build(:resource_file, filename: 'data_EPSG_4326.zip'),
                                   build(:resource_file, druid: 'mf519gg2738', filename:)
                                 ]),
                           build(:resource, :image)
                         ])
    end

    context 'when index map geojson' do
      let(:filename) { 'index_map.json' }

      describe 'loads viewer' do
        it 'shows the geojson' do
          expect(page).to have_css('.sul-embed-geo', count: 1, visible: :visible)
          expect(page).to have_css "[data-index-map=\"https://stacks.stanford.edu/file/mf519gg2738/#{filename}\"]"
          expect(page).to have_css('#sidebarContent')
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
          expect(page).to have_css "[data-index-map=\"https://stacks.stanford.edu/file/mf519gg2738/#{filename}\"]"
        end
      end
    end
  end
end
