require 'rails_helper'

describe 'download panel', js: true do
  pending('is pending due to the migration to imageX viewer') do 
  include PURLFixtures
  let(:request) { Embed::Request.new( {url: 'http://purl.stanford.edu/ab123cd4567'}) }
  before do
    stub_purl_response_with_fixture(image_purl)
  end
  describe 'toggle button' do
    before { send_embed_response }

    it 'should be present after a user clicks the button' do
      expect(page).to have_css('.sul-embed-download-panel', visible: false)
      page.find('button[data-sul-embed-toggle="sul-embed-download-panel"]', visible: true)

      page.find('[data-sul-embed-toggle="sul-embed-download-panel"]', match: :first).click
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
    it 'when selected should hide the button' do
      check("Hide download?")
      click_button 'Embed'

      expect(page).to_not have_css('button[data-sul-embed-toggle="sul-embed-download-panel"]')
    end
    it 'when not selected should display the button' do
      click_button 'Embed'

      expect(page).to have_css('button[data-sul-embed-toggle="sul-embed-download-panel"]')
    end
  end
end
end