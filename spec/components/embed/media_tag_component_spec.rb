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
  let(:druid) { 'bc123df4567' }
  let(:include_transcripts) { false }
  let(:many_primary_files) { false }

  before do
    render
  end

  context 'with a location restricted video' do
    let(:resource) { build(:resource, :video, files: [build(:resource_file, :video, :location_restricted)]) }

    it 'includes the file label as a data attribute' do
      expect(page).to have_css('[data-file-label="First Video"]')
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

  context 'with a stanford only video' do
    let(:resource_iteration) { instance_double(ActionView::PartialIteration, index: 1) }
    let(:resource) { build(:resource, :video, files: [build(:resource_file, :video, :stanford_only)]) }

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

  context 'with a world access video' do
    let(:resource_iteration) { instance_double(ActionView::PartialIteration, index: 3) }
    let(:resource) { build(:resource, :video, files: [build(:resource_file, :video, :world_downloadable)]) }

    it 'includes a data-src attribute for the dash player' do
      expect(page).to have_css('[data-src]', visible: :all)
    end

    it 'includes a data attribute that includes the url to check the users auth status' do
      expect(page).to have_css('video[data-auth-url]', visible: :all)
      auth_url = page.all('video[data-auth-url]', visible: :all).first['data-auth-url']
      expect(auth_url).to eq(Settings.streaming.auth_url)
    end

    it 'does not show any location restricted messages' do
      expect(page).not_to have_css('.sul-embed-media-access-restricted .line1', text: 'Restricted media cannot be played in your location')
    end
  end

  context 'with thumbnails' do
    context 'with an audio resource' do
      let(:resource) { build(:resource, :audio) }

      it 'includes the file level thumbnail data-attribute' do
        object = page.find('[data-slider-object="0"]')
        expect(object['data-thumbnail-url']).to match(%r{%2Faudio_1/square/75,75/})
      end
    end

    context 'with a video resource' do
      let(:resource) { build(:resource, :video) }

      it 'includes the file level thumbnail data-attribute when present' do
        object = page.find('[data-slider-object="0"]')
        expect(object['data-thumbnail-url']).to match(%r{%2Fvideo_1/square/75,75/})
      end
    end

    context 'with a resource that has a jpg, but no jp2' do
      let(:resource) do
        build(:resource, :video, files: [build(:resource_file, :video), build(:resource_file, :image, mimetype: 'image/jpeg')])
      end

      it 'does not use secondary files like jpgs as thumbnails' do
        object = page.find('[data-slider-object="0"]')
        expect(object['data-thumbnail-url']).to be_blank
      end
    end
  end

  context 'with image files within media objects' do
    let(:resource) do
      build(:resource, :image, files: [build(:resource_file, :image)])
    end

    it 'are included as top level objects' do
      expect(page).to have_css('div img.sul-embed-media-thumb')
    end

    it 'are scrollable' do
      object = page.find('[data-slider-object="0"]')

      expect(object['style']).to include 'overflow-y: scroll'
    end
  end

  describe 'with a poster' do
    context 'when a file level thumbnail is present' do
      let(:resource) { build(:resource, :video) }

      it 'includes a poster attribute' do
        expect(page).to have_css('video[poster]', visible: :all)
        video = page.find('video[poster]', visible: :all)
        expect(video['poster']).to match(%r{/bc123df4567%2Fvideo_1/full/})
      end
    end

    context 'when the file-level thumbnail is downloadable' do
      let(:resource) do
        build(:resource, :video,
              files: [
                build(:resource_file, :video),
                build(:resource_file, :image, :world_downloadable, filename: 'video_1.jp2')
              ])
      end

      it 'uses a large thumbnail' do
        video = page.find('video[poster]', visible: :all)
        expect(video['poster']).to match(%r{/full/!800,600/})
      end
    end

    context 'when a file level thumbnail is not present' do
      let(:resource) do
        build(:resource, :video,
              files: [build(:resource_file, :video)])
      end

      it 'does not include a poster attribute' do
        expect(page).not_to have_css('video[poster]', visible: :all)
      end
    end
  end

  context 'with audio' do
    let(:resource) { build(:resource, :audio) }

    it 'renders an audio tag in the provided document' do
      expect(page).to have_css('audio', visible: :all)
    end

    context 'when a file-level thumbnail is present' do
      let(:resource) { build(:resource, :audio) }

      it 'includes a poster attribute pointing at the thumbnail' do
        expect(page).to have_css('audio[poster]', visible: :all)
        audio = page.find('audio[poster]', visible: :all)
        expect(audio['poster']).to match(%r{/bc123df4567%2Faudio_1/full/})
      end
    end

    context 'when a file level thumbnail is not present' do
      let(:resource) do
        build(:resource, :audio, files: [build(:resource_file, :audio)])
      end

      it 'includes the default poster attribute' do
        expect(page).to have_css('audio[poster]', visible: :all)
        audio = page.find('audio[poster]', visible: :all)
        expect(audio['poster']).to match(/waveform-audio-poster/)
      end
    end
  end

  context 'with captions' do
    let(:resource) { build(:resource, :video) }
    let(:include_transcripts) { true }

    it 'has a track element' do
      expect(page).to have_css('track[src="https://stacks.stanford.edu/file/druid:bc123df4567/abc_123_cap.webvtt"]')
    end
  end

  context 'with captions for multiple languages' do
    let(:resource) do
      build(:resource, :video, files: [build(:resource_file, :video),
                                       build(:resource_file, :vtt, language: 'en'),
                                       build(:resource_file, :vtt, language: 'ru')])
    end

    let(:include_transcripts) { true }

    it 'has track elements with multiple languages' do
      expect(page).to have_css('track[srclang="en"][label="English"]')
      expect(page).to have_css('track[srclang="ru"][label="Russian"]')
    end
  end

  context 'with caption with no specified language' do
    let(:resource) do
      build(:resource, :video, files: [build(:resource_file, :video),
                                       build(:resource_file, :vtt)])
    end
    let(:include_transcripts) { true }

    it 'has a track element with code and label for English' do
      expect(page).to have_css('track[srclang="en"][label="English"]')
    end
  end
end
