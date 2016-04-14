require 'rails_helper'

describe 'was seed viewer public', js: true do
  include PURLFixtures
  include WasSeedThumbsFixtures

  before do
    allow_any_instance_of(Embed::Viewer::WasSeed).to receive(:thumbs_list).and_return(thumbs_list_fixtures)
    stub_purl_response_with_fixture(was_seed_purl)
    visit_sandbox
    fill_in_default_sandbox_form
    click_button 'Embed'
  end

  describe 'loading was-seed-viewer' do
    it 'displays the viewer on the frame' do
      expect(page).to have_css('.sul-embed-was-seed', count: 1, visible: true)
      expect(page).to have_css('.sul-embed-was-thumb-item', count: 4, visible: true)
      expect(page).to have_css('.sul-embed-was-thumb-item-div', count: 4, visible: true)
    end
    it 'loads the SLY slider and scroll' do
      expect(page).to have_css('.sul-embed-thumb-slider-scroll', count: 1, visible: true)
      within '.sul-embed-was-seed' do
        expect(page.find('.sul-embed-was-thumb-list')['style']).to match(/webkit-transform: translateZ/)
      end
    end
    it 'selects the one before the last to be active' do
      expect(page).to have_css('.active', count: 1, visible: true)
      expect(page.find('.active').text).to eq('12-Oct-2013')
    end
    it 'changes the active one with the select' do
      expect(page.find('.active').text).to eq('12-Oct-2013')
      page.first('.sul-embed-was-thumb-item').click
      expect(page.find('.active').text).to eq('29-Nov-2012')
    end
  end

  def thumbs_list_fixtures
    JSON.parse(thumbs_list)['thumbnails']
  end
end
