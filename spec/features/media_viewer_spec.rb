# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'media viewer', :js do
  include PurlFixtures
  let(:purl) { video_purl }
  let(:stub_auth) { nil }

  before do
    stub_auth
    stub_purl_response_with_fixture(purl)
    visit_iframe_response
  end

  it 'renders player in html' do
    expect(page).to have_css('video', visible: :all)
  end

  describe 'footer panels' do
    it 'renders a toggle-able metadata panel' do
      find('button.sul-embed-footer-tool.sul-i-infomation-circle').click
      within '.sul-embed-metadata-panel' do
        expect(page).to have_css '.sul-embed-panel-title', text: 'stupid dc title of video'
      end
    end

    it 'renders a download panel' do
      expect(page).to have_css('.sul-embed-download-panel', visible: :all)
      toggle_download_panel
      expect(page).to have_css('.sul-embed-download-panel', visible: :visible)
      expect(page).to have_css('ul.sul-embed-download-list', count: 1)
      expect(page).to have_css('.sul-embed-download-list li a', visible: :visible, count: 3, text: /^Download/)
    end
  end

  context 'with a single A/V file' do
    let(:purl) { audio_purl }

    it 'does does not have the thumbnail slider panel' do
      expect(page).to have_css('.sul-embed-container', visible: :visible) # to wait for the viewer to load
      expect(page).not_to have_css('.sul-embed-thumb-slider-container', visible: :visible)
    end
  end

  describe 'Stanford link' do
    context 'when the user can access the file' do
      let(:stub_auth) { StubAuthEndpoint.set_success! }

      it 'hides the link' do
        expect(page).to have_css('.sul-embed-container', visible: :visible) # to wait for the viewer to load
        expect(page).not_to have_css('.sul-embed-auth-link a', visible: :visible)
        expect(page).not_to have_content 'Restricted media cannot be played in your location.'
      end
    end

    context 'when the user cannot access the file' do
      let(:stub_auth) { StubAuthEndpoint.set_stanford! }

      it 'shows the Stanford link' do
        expect(page).to have_css('.sul-embed-auth-link a', visible: :visible)
      end
    end
  end

  context 'with multiple A/V files' do
    # The ajax request that displays the video does not fire in this context
    # so we are checking for a non-visible video in the first case (even though it should be visible)
    it 'has a toggle-able thumbnail slider panel' do
      expect(page).to have_css('.sul-embed-thumb-slider-container', visible: :visible)
      expect(page).to have_css('.sul-embed-thumb-slider-open-close', visible: :visible)
      expect(page).to have_css('.sul-embed-thumb-slider[aria-expanded="false"]', visible: :all)
      expect(page).to have_css('.sul-embed-thumb-slider-open-close[aria-expanded="false"]', visible: :visible)
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-thumb-slider[aria-expanded="true"]', visible: :visible)
      expect(page).to have_css('.sul-embed-thumb-slider-open-close[aria-expanded="true"]', visible: :visible)
      expect(page).to have_css('[data-slider-object="0"] video', visible: :all)
      expect(page).to have_css('[data-slider-object="1"] video', visible: :all)

      within('.sul-embed-thumb-slider') do
        expect(page).to have_css('.sul-embed-slider-thumb', count: 3)
      end
    end

    it 'has the class indicating Stanford only for stanford restricted files (with screenreader text)' do
      expect(page).not_to have_css('.sul-embed-thumb-slider', visible: :visible)
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-thumb-slider', visible: :visible)

      expect(page).to have_css('.sul-embed-thumb-stanford-only', count: 1)
      expect(page).to have_css('.sul-embed-thumb-stanford-only', text: 'Second Video')
      expect(page).to have_css('.sul-embed-thumb-stanford-only .sul-embed-text-hide', text: 'Stanford only', count: 1)
      expect(page).not_to have_css('.sul-embed-thumb-stanford-only', text: 'abc_123.mp4')
    end
  end

  context 'with a previewable file within a media object' do
    let(:purl) { video_purl_with_image }

    it 'includes a previewable image as a top level object' do
      expect(page).to have_css('div img.sul-embed-media-thumb', visible: :all)
    end

    it 'includes a thumb for the previewable image in the thumb slider' do
      expect(page).to have_css('.sul-embed-thumb-slider', visible: :all)
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-thumb-slider')
      expect(page).to have_css('.sul-embed-thumb-slider', visible: :visible)

      expect(page).to have_css('.sul-embed-media-square-icon')
      expect(page).to have_css('.sul-embed-thumb-label', text: 'Image of media (1 of 1)')
    end
  end

  context 'with a location restricted file within a media object' do
    it 'displays the restricted text with the appropriate styling' do
      expect(page).not_to have_css('.sul-embed-thumb-slider', visible: :visible)
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-thumb-slider', visible: :visible)

      expect(page).to have_css('.sul-embed-location-restricted-text', text: '(Restricted)', count: 1)
      expect(page).to have_css('.sul-embed-media-slider-thumb', text: '(Restricted) abc_123.mp4')
    end
  end

  context 'with duration related info' do
    it 'displays available duration in parens after the title (video)' do
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-media-slider-thumb', text: 'abc_123.mp4 (1:02:03)')
    end

    it 'displays no duration info after title when there is no duration we can interpret' do
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-media-slider-thumb', text: /Second Video$/)
    end

    context 'with invalid duration' do
      let(:purl) { invalid_video_duration_purl }

      it 'displays as if there were no duration in the purl xml' do
        page.find('.sul-embed-thumb-slider-open-close').click
        expect(page).to have_css('.sul-embed-media-slider-thumb', text: 'abc_123.mp4')
      end
    end

    context 'with an audio' do
      let(:purl) { audio_purl_multiple }

      it 'displays available duration in parens after the title' do
        page.find('.sul-embed-thumb-slider-open-close').click
        expect(page).to have_css('.sul-embed-media-slider-thumb', text: 'abc_123.mp3 (0:43)')
      end

      it 'displays no duration info after title when there is no duration we can interpret' do
        page.find('.sul-embed-thumb-slider-open-close').click
        expect(page).to have_css('.sul-embed-media-slider-thumb', text: 'abc_456.mp3')
      end
    end
  end

  context 'with long titles' do
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
