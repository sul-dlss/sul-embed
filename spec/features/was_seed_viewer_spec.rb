# frozen_string_literal: true

require 'rails_helper'

describe 'was seed viewer public', js: true do
  include PurlFixtures
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
      expect(page).to have_css('.active', count: 1, visible: true)

      within '.active' do
        expect(page).to have_css('.sul-embed-was-thumb-item-date', text: '12-Oct-2013')
      end
    end

    it 'changes the active one with the select' do
      expect(page).to have_css('.active', count: 1, visible: true)

      within '.active' do
        expect(page).to have_css('.sul-embed-was-thumb-item-date', text: '12-Oct-2013', visible: true)
      end

      first_item = page.first('.sul-embed-was-thumb-item')
      first_item_text = first_item.find('.sul-embed-was-thumb-item-date').text

      expect(first_item_text).not_to eq('12-Oct-2013') # Make sure the first one is not the one we're already on

      first_item.click

      within '.active' do
        expect(page).to have_css('.sul-embed-was-thumb-item-date', text: first_item_text, visible: true)
      end
    end

    it 'links to the memento URI with a _parent target' do
      expect(page).to have_css('.sul-embed-was-thumb-item-date a[target="_parent"]')
    end
  end
end
