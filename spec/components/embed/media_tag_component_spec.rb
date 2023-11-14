# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::MediaTagComponent, type: :component do
  include PurlFixtures
  subject(:render) do
    render_inline(
      described_class.new(
        resource:, resource_iteration:, druid:, include_transcripts:, many_primary_files:
      )
    )
  end

  let(:resource_iteration) { instance_double(ActionView::PartialIteration, index: 0) }
  let(:resource) { Embed::Purl.new(druid).contents.first }
  let(:druid) { 'bc123df4567' }
  let(:purl) { video_purl }
  let(:include_transcripts) { false }
  let(:many_primary_files) { false }

  before do
    stub_purl_xml_response_with_fixture(purl)
    render
  end

  context 'with the first resource' do
    it 'includes the file label as a data attribute' do
      expect(page).to have_css('[data-file-label="abc_123.mp4"]')
    end

    it 'includes a data attribute for the thumb-slider bar' do
      expect(page).to have_css('[data-slider-object="0"]')
    end

    it 'is not scrollable' do
      object = page.find('[data-slider-object="0"]')

      expect(object['style']).not_to match(/overflow.*scroll/)
    end

    it 'includes a data-src attribute for the dash player' do
      expect(page).to have_css('[data-src]', visible: :all)
    end

    it 'includes a data attribute that includes the url to check the users auth status' do
      expect(page).to have_css('video[data-auth-url]', visible: :all)
      auth_url = page.all('video[data-auth-url]', visible: :all).first['data-auth-url']
      expect(auth_url).to eq(Settings.streaming.auth_url)
    end
  end

  context 'with the second resource' do
    let(:resource_iteration) { instance_double(ActionView::PartialIteration, index: 1) }
    let(:resource) { Embed::Purl.new(druid).contents.second }

    it 'includes the file label as a data attribute' do
      expect(page).to have_css('[data-file-label="Second Video"]')
    end

    it 'includes a data attribute for the thumb-slider bar' do
      expect(page).to have_css('[data-slider-object="1"]')
    end

    it 'includes a data-src attribute for the dash player' do
      expect(page).to have_css('[data-src]', visible: :all)
    end

    it 'includes a data attribute that includes the url to check the users auth status' do
      expect(page).to have_css('video[data-auth-url]', visible: :all)
      auth_url = page.all('video[data-auth-url]', visible: :all).first['data-auth-url']
      expect(auth_url).to eq(Settings.streaming.auth_url)
    end
  end

  context 'with the fourth resource' do
    let(:resource_iteration) { instance_double(ActionView::PartialIteration, index: 3) }
    let(:resource) { Embed::Purl.new(druid).contents.fourth }

    it 'includes a data-src attribute for the dash player' do
      expect(page).to have_css('[data-src]', visible: :all)
    end

    it 'includes a data attribute that includes the url to check the users auth status' do
      expect(page).to have_css('video[data-auth-url]', visible: :all)
      auth_url = page.all('video[data-auth-url]', visible: :all).first['data-auth-url']
      expect(auth_url).to eq(Settings.streaming.auth_url)
    end
  end

  context 'with a single video' do
    let(:purl) { single_video_purl }

    it 'includes a 100% height attribute' do
      expect(page).to have_css("video[height='100%']", visible: :all)
    end

    it 'shows location restricted messages to the screen reader' do
      expect(page).to have_css('video[aria-labelledby="access-restricted-message-div-0"]', visible: :all)
      expect(page).to have_css('div#access-restricted-message-div-0')
    end

    it 'shows a location restricted message in place of the video' do
      expect(page).to have_css('.sul-embed-media-access-restricted .line1', text: 'Restricted media cannot be played in your location')
    end
  end

  context 'with a single video open to the world' do
    let(:purl) { video_purl_unrestricted }

    it 'does not show any location restricted messages' do
      expect(page).not_to have_css('.sul-embed-media-access-restricted .line1', text: 'Restricted media cannot be played in your location')
    end
  end

  context 'with file and object level thumbnails' do
    let(:purl) { file_and_object_level_thumb_purl }

    it 'does not include object level thumbnails' do
      expect(page).to have_css('[data-file-label="audio.mp3"]', visible: :all)
      expect(page).not_to have_css('[data-file-label="thumb.jp2"]', visible: :all)
    end

    it 'does not include file level thumbnails' do
      expect(page).not_to have_css('[data-file-label="audio_1.jp2"]', visible: :all)
    end

    context 'with the second resource' do
      let(:resource_iteration) { instance_double(ActionView::PartialIteration, index: 1) }
      let(:resource) { Embed::Purl.new(druid).contents.second }

      it 'includes the file level thumbnail data-attribute when present' do
        object = page.find('[data-slider-object="1"]')
        expect(object['data-thumbnail-url']).to match(%r{%2Fvideo_1/square/75,75/})
      end
    end

    context 'with the third resource' do
      let(:resource_iteration) { instance_double(ActionView::PartialIteration, index: 2) }
      let(:resource) { Embed::Purl.new(druid).contents.third }

      it 'does not mistakenly use secondary files like jpgs as thumbnails' do
        object = page.find('[data-slider-object="2"]')
        expect(object['data-thumbnail-url']).to be_blank
      end
    end
  end

  context 'with previewable files within media objects' do
    let(:purl) { video_purl_with_image }
    let(:resource_iteration) { instance_double(ActionView::PartialIteration, index: 1) }
    let(:resource) { Embed::Purl.new(druid).contents.second }

    it 'are included as top level objects' do
      expect(page).to have_css('div img.sul-embed-media-thumb')
    end

    it 'are scrollable' do
      object = page.find('[data-slider-object="1"]')

      expect(object['style']).to include 'overflow-y: scroll'
    end
  end

  context 'with video' do
    it 'renders a video tag in the provided document' do
      expect(page).to have_css('video', visible: :all)
    end
  end

  describe 'with a poster' do
    context 'when a file level thumbnail is present' do
      let(:purl) { file_and_object_level_thumb_purl }
      let(:resource_iteration) { instance_double(ActionView::PartialIteration, index: 1) }
      let(:resource) { Embed::Purl.new(druid).contents.second }

      it 'includes a poster attribute' do
        expect(page).to have_css('video[poster]', visible: :all)
        video = page.find('video[poster]', visible: :all)
        expect(video['poster']).to match(%r{/bc123df4567%2Fvideo_1/full/})
      end
    end

    context 'when the file-level thumbnail is downloadable' do
      let(:purl) { file_and_object_level_downloadable_thumb_purl }

      let(:resource_iteration) { instance_double(ActionView::PartialIteration, index: 1) }
      let(:resource) { Embed::Purl.new(druid).contents.second }

      it 'uses a large thumbnail' do
        video = page.find('video[poster]', visible: :all)
        expect(video['poster']).to match(%r{/full/!800,600/})
      end
    end

    context 'when a file level thumbnail is not present' do
      it 'does not include a poster attribute' do
        expect(page).not_to have_css('video[poster]', visible: :all)
      end
    end
  end

  context 'with audio' do
    let(:purl) { audio_purl }

    it 'renders an audio tag in the provided document' do
      expect(page).to have_css('audio', visible: :all)
    end

    context 'when a file-level thumbnail is present' do
      let(:purl) { audio_purl_with_thumbnail }

      it 'includes a poster attribute pointing at the thumbnail' do
        expect(page).to have_css('audio[poster]', visible: :all)
        audio = page.find('audio[poster]', visible: :all)
        expect(audio['poster']).to match(%r{/bc123df4567%2Fabc_123_thumb/full/})
      end
    end

    context 'when a file level thumbnail is not present' do
      it 'includes the default poster attribute' do
        expect(page).to have_css('audio[poster]', visible: :all)
        audio = page.find('audio[poster]', visible: :all)
        expect(audio['poster']).to match(/waveform-audio-poster/)
      end
    end
  end

  context 'with captions' do
    let(:purl) { video_purl_with_vtt }
    let(:include_transcripts) { true }

    it 'has a track element' do
      expect(page).to have_css('track[src="https://stacks.stanford.edu/file/druid:bc123df4567/abc_123_cap.webvtt"]')
    end
  end
end
