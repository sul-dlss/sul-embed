# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Media viewer', :js do
  include PurlFixtures
  let(:purl) { video_purl }
  let(:stub_auth) { nil }

  before do
    allow(Settings.enabled_features).to receive(:new_component).and_return(true)
    stub_auth
    stub_purl_xml_response_with_fixture(purl)
    visit_iframe_response
  end

  context 'when the file has Stanford login access' do
    context 'when the user can access the file' do
      let(:stub_auth) { StubAuthEndpoint.set_success! }

      it 'hides the link' do
        expect(page).not_to have_button('login')
      end
    end

    context 'when the user cannot access the file' do
      let(:stub_auth) { StubAuthEndpoint.set_stanford! }

      it 'shows the Stanford link' do
        expect(page).to have_button 'Log in'
      end
    end
  end

  context 'with multiple A/V files' do
    # The ajax request that displays the video does not fire in this context
    # so we are checking for a non-visible video in the first case (even though it should be visible)
    it 'displays the viewer' do
      click_button 'Display sidebar'
      within 'aside.open' do
        expect(page).to have_content 'About this item'
        click_button 'Content'
        expect(page).to have_content 'Media Content'
        expect(page).to have_css('.sul-embed-media-slider-thumb', count: 3)

        # It indicates that one of the files is Stanford only and has no duration
        expect(page).to have_css('.sul-embed-thumb-stanford-only', text: /Second Video$/)

        # One is restricted and has a duration
        expect(page).to have_css('.sul-embed-location-restricted-text', text: '(Restricted)')
        expect(page).to have_css('.sul-embed-media-slider-thumb', text: '(Restricted) First Video (1:02:03)')
        click_button 'Use and reproduction'
        expect(page).to have_content 'Rights'
      end

      click_button 'Display sidebar'
      expect(page).not_to have_css 'aside.open'

      expect(page).to have_css('video', visible: :all)
    end
  end

  context 'with a previewable file within a media object' do
    let(:purl) { video_purl_with_image }

    it 'includes a previewable image as a top level object' do
      expect(page).to have_css('div .osd', visible: :hidden)

      click_button 'Display sidebar'
      within 'aside.open' do
        click_button 'Content'

        # Setting blank alt text apparently makes the component invisible in copybara
        expect(page).to have_css('.sul-embed-media-square-icon', visible: :all)
        expect(page).to have_content('Image of media (1 of 1)')
      end
    end
  end

  context 'with invalid duration' do
    let(:purl) { invalid_video_duration_purl }

    it 'displays as if there were no duration in the purl xml' do
      click_button 'Display sidebar'
      within 'aside.open' do
        click_button 'Content'

        expect(page).to have_css('.sul-embed-media-slider-thumb', text: /First Video$/)
      end
    end
  end

  context 'with an audio' do
    let(:purl) { audio_purl_multiple }

    it 'displays available duration in parens after the title' do
      click_button 'Display sidebar'
      within 'aside.open' do
        click_button 'Content'

        expect(page).to have_css('.sul-embed-media-slider-thumb', text: 'First Audio (0:43)')

        # No duration
        expect(page).to have_css('.sul-embed-media-slider-thumb', text: /Second Audio$/)
      end
    end
  end

  context 'with long titles' do
    let(:purl) { long_label_purl }

    it 'truncates at 45 characters of combined restriction and title text' do
      click_button 'Display sidebar'
      within 'aside.open' do
        click_button 'Content'
        expect(page).to have_css('.sul-embed-media-slider-thumb', text: /^\(Restricted\) The First Video Has An Overly Lo… \(1:02:03\)$/)

        # displays the whole title if it is under the length limit
        expect(page).to have_css('.sul-embed-media-slider-thumb', text: /^2nd Video Has A Long Title, But Not Too Long$/)
      end
    end
  end
end
