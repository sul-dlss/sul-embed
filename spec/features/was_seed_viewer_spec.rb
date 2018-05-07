require 'rails_helper'

describe 'was seed viewer public', js: true do
  include PURLFixtures
  include WasSeedThumbsFixtures

  before do
    allow_any_instance_of(Embed::Viewer::WasSeed).to receive(:thumbs_list).and_return(thumbs_list_fixtures)
    stub_purl_response_with_fixture(was_seed_purl)
    visit_iframe_response
  end

  describe 'loading was-seed-viewer' do
    it 'displays the viewer on the frame' do
      expect(page).to have_css('.sul-embed-was-seed', count: 1)
      expect(page).to have_css('.sul-embed-was-thumb-item', count: 4, visible: false)
      expect(page).to have_css('.sul-embed-was-thumb-item-div', count: 4, visible: false)
    end
    it 'loads the SLY slider and scroll' do
      expect(page).to have_css('.sul-embed-thumb-slider-scroll', count: 1)
      within '.sul-embed-was-seed' do
        expect(page.find('.sul-embed-was-thumb-list')['style']).to match(/transform: translateZ/)
      end
    end
    it 'selects the one before the last to be active' do
      expect(page).to have_css('.active', count: 1)
      expect(page.find('.active').text).to eq('12-Oct-2013')
    end
    it 'changes the active one with the select' do
      expect(page.find('.active').text).to eq('12-Oct-2013')
      page.first('.sul-embed-was-thumb-item').click
      expect(page.find('.active').text).to eq('29-Nov-2012')
    end

    it 'links to the memento URI with a _parent target' do
      expect(page).to have_css('.sul-embed-was-thumb-item-date a[target="_parent"]')
    end
  end
end
