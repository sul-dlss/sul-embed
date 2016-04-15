require 'rails_helper'

describe 'media viewer', js: true do
  include PURLFixtures
  let(:purl) { video_purl }
  before do
    stub_purl_response_with_fixture(purl)
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
      expect(page).to have_css('.sul-embed-download-list li a', visible: true, count: 3, text: /^Download/)
    end
  end

  context 'single A/V file' do
    let(:purl) { audio_purl }
    it 'does does not have the thumbnail slider panel' do
      expect(page).not_to have_css('.sul-embed-thumb-slider-container', visible: true)
    end
  end

  context 'multiple A/V files' do
    it 'has a toggle-able thumbnail slider panel' do
      expect(page).to have_css('.sul-embed-thumb-slider-container', visible: true)
      expect(page).to have_css('.sul-embed-thumb-slider-open-close', visible: true)
      expect(page).not_to have_css('.sul-embed-thumb-slider', visible: true)
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-thumb-slider', visible: true)
      expect(page).to have_css('video[data-slider-object="0"]', visible: true)
      expect(page).to have_css('video[data-slider-object="1"]', visible: false)

      within('.sul-embed-thumb-slider') do
        expect(page).to have_css('.sul-embed-slider-thumb', count: 2)
      end
    end
  end
end
