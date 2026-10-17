# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Media::PlayerComponent, type: :component do
  subject(:render) do
    render_inline(described_class.new(resource:, druid:, slot:))
  end

  let(:slot) { build(:slot, file: resource.primary_file, type: resource.type) }
  let(:druid) { 'bc123df4567' }

  before do
    render
  end

  context 'with a video' do
    let(:resource) { build(:resource, :video) }

    it 'uses the Video.js v10 custom elements' do
      expect(page).to have_css('video-player video-skin hlsjs-video', visible: :all)
    end
  end

  describe 'with a poster' do
    context 'when a file level thumbnail is present' do
      let(:resource) { build(:resource, :video) }

      it 'includes a poster attribute' do
        expect(page).to have_css('hlsjs-video[poster]', visible: :all)
        video = page.find('hlsjs-video[poster]', visible: :all)
        expect(video['poster']).to match(%r{/bc123df4567%2Fvideo_1/full/})
      end
    end

    context 'when the file-level thumbnail is downloadable' do
      let(:resource) do
        build(:resource, :video,
              files: [
                build(:media_file, :video),
                build(:media_file, :image, :world_downloadable, filename: 'video_1.jp2')
              ])
      end

      it 'uses a large thumbnail' do
        video = page.find('hlsjs-video[poster]', visible: :all)
        expect(video['poster']).to match(%r{/full/!800,600/})
      end
    end

    context 'when a file level thumbnail is not present' do
      let(:resource) do
        build(:resource, :video,
              files: [build(:media_file, :video)])
      end

      it 'shows the locked icon' do
        video = page.find('hlsjs-video[poster]', visible: :all)
        expect(video['poster']).to match(/locked-media-poster/)
      end
    end
  end

  context 'with audio' do
    let(:resource) { build(:resource, :audio) }

    context 'when a file level thumbnail is not present' do
      let(:resource) do
        build(:resource, :audio, files: [build(:media_file, :audio)])
      end

      it 'includes the default poster attribute' do
        audio = page.find('hlsjs-video[poster]', visible: :all)
        expect(audio['poster']).to match(/waveform-audio-poster/)
      end
    end
  end

  context 'with captions' do
    let(:resource) { build(:resource, :video) }

    it 'has a track element' do
      expect(page).to have_css('track[src="https://stacks.stanford.edu/file/bc123df4567/abc_123_cap.vtt"]')
    end

    it 'configures the media source for authorization' do
      expect(page).to have_css(
        'hlsjs-video[data-media-src="https://stacks.stanford.edu/file/bc123df4567/abc_123.mp4"]',
        visible: :all
      )
    end

    context 'with captions for multiple languages' do
      let(:resource) do
        build(:resource, :video, files: [build(:media_file, :video),
                                         build(:media_file, :caption, language: 'en'),
                                         build(:media_file, :caption, language: 'ru')])
      end

      it 'has track elements with multiple languages' do
        expect(page).to have_css('track[srclang="en"][label="English"]')
        expect(page).to have_css('track[srclang="ru"][label="Russian"]')
      end

      # The transcript panel fetches these itself rather than reading the player's text
      # tracks, which only expose the cues of the language currently on screen.
      it 'lists every caption file for the transcript panel' do
        captions = JSON.parse(page.find('hlsjs-video', visible: :all)['data-captions'])

        expect(captions).to eq [
          { 'language' => 'en', 'label' => 'English',
            'url' => 'https://stacks.stanford.edu/file/bc123df4567/abc_123_cap.vtt' },
          { 'language' => 'ru', 'label' => 'Russian',
            'url' => 'https://stacks.stanford.edu/file/bc123df4567/abc_123_cap.vtt' }
        ]
      end
    end

    context 'with caption with no specified language' do
      let(:resource) do
        build(:resource, :video, files: [build(:media_file, :video),
                                         build(:media_file, :caption)])
      end

      it 'has a track element with code and label for English' do
        expect(page).to have_css('track[srclang="en"][label="English"]')
      end
    end
  end
end
