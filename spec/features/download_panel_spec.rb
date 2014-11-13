require 'rails_helper'

describe 'download panel' do
  include PURLFixtures
  let(:request) { Embed::Request.new( {url: 'http://purl.stanford.edu/ab123cd4567'}) }
  before do
    stub_purl_response_with_fixture(image_purl)
  end
  describe 'toggle button' do
    before { send_embed_response }

    it 'should be present after a user clicks the button', js: true do
      expect(page).to have_css('.sul-embed-download-panel', visible: false)
      page.find('button[data-toggle="sul-embed-download-panel"]', visible: true)

      page.find('[data-toggle="sul-embed-download-panel"]', match: :first).click

      expect(page).to have_css('.sul-embed-download-panel', visible: true)

      expect(page).to have_css('.sul-embed-panel-item-label', text: '')      

      expect(page).to have_css('.sul-embed-download-small', visible: true)
      expect(page).to have_css('.sul-embed-download-medium', visible: true)
      expect(page).to have_css('.sul-embed-download-large', visible: true)
      expect(page).to have_css('.sul-embed-download-xlarge', visible: true)
      expect(page).to have_css('.sul-embed-download-full', visible: true)
    end
  end
  describe 'hide download?' do
    before do
      visit_sandbox
      fill_in_default_sandbox_form
    end
    it 'when selected should hide the button', js: true do
      check("Hide download?")
      click_button 'Embed'

      expect(page).to_not have_css('button[data-toggle="sul-embed-download-panel"]')
    end
    it 'when not selected should display the button', js: true do
      click_button 'Embed'

      expect(page).to have_css('button[data-toggle="sul-embed-download-panel"]')
    end
  end
end
