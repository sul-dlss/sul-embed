require 'rails_helper'

describe 'media viewer', js: true do
  include PURLFixtures
  let(:purl) { video_purl }
  before do
    stub_purl_response_with_fixture(purl)
    visit_iframe_response
  end

  it 'renders player in html' do
    expect(page).to have_css('video', visible: false)
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
    # The ajax request that displays the video does not fire in this context
    # so we are checking for a non-visible video in the first case (even though it should be visible)
    it 'has a toggle-able thumbnail slider panel' do
      expect(page).to have_css('.sul-embed-thumb-slider-container', visible: true)
      expect(page).to have_css('.sul-embed-thumb-slider-open-close', visible: true)
      expect(page).to have_css('.sul-embed-thumb-slider[aria-expanded="false"]', visible: false)
      expect(page).to have_css('.sul-embed-thumb-slider-open-close[aria-expanded="false"]', visible: true)
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-thumb-slider[aria-expanded="true"]', visible: true)
      expect(page).to have_css('.sul-embed-thumb-slider-open-close[aria-expanded="true"]', visible: true)
      expect(page).to have_css('[data-slider-object="0"] video', visible: false)
      expect(page).to have_css('[data-slider-object="1"] video', visible: false)

      within('.sul-embed-thumb-slider') do
        expect(page).to have_css('.sul-embed-slider-thumb', count: 2)
      end
    end

    it 'has the class indicating Stanford only for stanford restricted files' do
      expect(page).not_to have_css('.sul-embed-thumb-slider', visible: true)
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-thumb-slider', visible: true)

      expect(page).to have_css('.sul-embed-thumb-stanford-only', count: 1)
      expect(page).to have_css('.sul-embed-thumb-stanford-only', text: 'Second Video')
      expect(page).not_to have_css('.sul-embed-thumb-stanford-only', text: 'abc_123.mp4')
    end
  end

  context 'a previewable file within a media object' do
    let(:purl) { video_purl_with_image }

    it 'includes a previewable image as a top level object' do
      expect(page).to have_css('div img.sul-embed-media-thumb', visible: false)
    end

    it 'includes a thumb for the previewable image in the thumb slider' do
      expect(page).to have_css('.sul-embed-thumb-slider', visible: false)
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-thumb-slider', visible: true)

      expect(page).to have_css('.sul-embed-media-square-icon')
      expect(page).to have_css('.sul-embed-thumb-label', text: 'Image of media (1 of 1)')
    end
  end

  context 'a location restricted file within a media object' do
    it 'displays the restricted text with the appropriate styling' do
      expect(page).not_to have_css('.sul-embed-thumb-slider', visible: true)
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-thumb-slider', visible: true)

      expect(page).to have_css('.sul-embed-location-restricted-text', text: '(Restricted)', count: 1)
      expect(page).to have_css('.sul-embed-media-slider-thumb', text: '(Restricted) abc_123.mp4')
    end
  end

  context 'duration related info' do
    it 'displays available duration in parens after the title' do
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-media-slider-thumb', text: 'abc_123.mp4 (1:02:03)')
    end
    it 'displays no duration info after title when there is no duration we can interpret' do
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-media-slider-thumb', text: /^Second Video$/)
    end
    context 'invalid duration format' do
      let(:purl) { invalid_video_duration_purl }
      it 'displays as if there were no duration in the purl xml' do
        page.find('.sul-embed-thumb-slider-open-close').click
        expect(page).to have_css('.sul-embed-media-slider-thumb', text: 'abc_123.mp4')
      end
    end
  end

  context 'graceful display of long titles' do
    let(:purl) { long_label_purl }
    it 'truncates at 45 characters of combined restriction and title text' do
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-media-slider-thumb', text: /^\(Restricted\) The First Video Has An Overly Lo… \(1:02:03\)$/)
    end
    it 'displays the whole title if it is under the length limit' do
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-media-slider-thumb', text: /^2nd Video Has A Long Title, But Not Too Long$/)
    end
  end
end
