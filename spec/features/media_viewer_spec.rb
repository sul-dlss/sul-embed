require 'rails_helper'

describe 'media viewer', js: true do
  include PURLFixtures
  before do
    stub_purl_response_with_fixture(video_purl)
    visit_sandbox
    fill_in_default_sandbox_form('ignored')
    click_button 'Embed'
  end

  it 'renders player in html' do
    expect(page).to have_css('video')
  end

  describe 'footer panels' do
    it 'renders a toggle-able metadata panel' do
      find('button.sul-embed-footer-tool.sul-i-infomation-circle').click
      within '.sul-embed-metadata-panel' do
        expect(page).to have_css '.sul-embed-panel-title', text: 'stupid dc title of video'
      end
    end

    it 'renders a download panel' do
      expect(page).to have_css('.sul-embed-download-panel', visible: false)
      toggle_download_panel
      expect(page).to have_css('.sul-embed-download-panel', visible: true)
      expect(page).to have_css('ul.sul-embed-download-list', count: 1)
      expect(page).to have_css('.sul-embed-download-list li a', visible: true, count: 2, text: /^Download/)
    end
  end
end
