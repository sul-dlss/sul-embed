# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::StacksMediaStream do
  subject(:stream) { described_class.new(druid: 'ab012cd3456', file:) }

  let(:file) { instance_double(Embed::Purl::ResourceFile, title: media_filename, thumbnail:) }
  let(:media_filename) { 'def.mp4' }
  let(:streaming_base_url) { Settings.stream.url }
  let(:thumbnail) { instance_double(Embed::Purl::ResourceFile, title: 'thumb.jp2', world_downloadable?: world_downloadable) }
  let(:world_downloadable) { true }

  describe '#to_thumbnail_url' do
    context 'when file has a world-downloadable thumbnail' do
      it 'uses a high-resolution thumbnail' do
        expect(stream.to_thumbnail_url).to match(%r{ab012cd3456%2Fthumb/full/!800,600})
      end
    end

    context 'when file has a non-world-downloadable thumbnail' do
      let(:world_downloadable) { false }

      it 'uses a standard thumbnail' do
        expect(stream.to_thumbnail_url).to match(%r{ab012cd3456%2Fthumb/full/!400,400})
      end
    end

    context 'when file has no thumbnail' do
      let(:thumbnail) { nil }

      context 'when file is audio' do
        let(:media_filename) { 'def.m4a' }

        it 'uses the default audio thumbnail' do
          expect(stream.to_thumbnail_url).to match(/waveform-audio-poster/)
        end
      end

      context 'when file is not audio' do
        let(:media_file) { 'def.mp4' }

        it 'returns nil' do
          expect(stream.to_thumbnail_url).to be_nil
        end
      end
    end
  end

  describe '#to_playlist_url' do
    context 'with mp4 video' do
      it 'has the expected URL' do
        expect(stream.to_playlist_url).to eq "https://#{streaming_base_url}/ab/012/cd/3456/mp4:def.mp4/playlist.m3u8"
      end
    end

    context 'with mov video' do
      let(:media_filename) { 'def.mov' }

      it 'has the expected URL' do
        expect(stream.to_playlist_url).to eq "https://#{streaming_base_url}/ab/012/cd/3456/mp4:def.mov/playlist.m3u8"
      end
    end

    context 'with mp3 audio' do
      let(:media_filename) { 'def.mp3' }

      it 'has the expected URL' do
        expect(stream.to_playlist_url).to eq "https://#{streaming_base_url}/ab/012/cd/3456/mp3:def.mp3/playlist.m3u8"
      end
    end

    context 'with an unknown file type' do
      let(:media_filename) { 'def.xxx' }

      it 'returns nil' do
        expect(stream.to_playlist_url).to be_nil
      end
    end
  end

  describe '#to_manifest_url' do
    context 'with mp4 video' do
      it 'has the expected URL' do
        expect(stream.to_manifest_url).to eq "https://#{streaming_base_url}/ab/012/cd/3456/mp4:def.mp4/manifest.mpd"
      end
    end

    context 'with mov video' do
      let(:media_filename) { 'def.mov' }

      it 'has the expected URL' do
        expect(stream.to_manifest_url).to eq "https://#{streaming_base_url}/ab/012/cd/3456/mp4:def.mov/manifest.mpd"
      end
    end

    context 'with mp3 audio' do
      let(:media_filename) { 'def.mp3' }

      it 'has the expected URL' do
        expect(stream.to_manifest_url).to eq "https://#{streaming_base_url}/ab/012/cd/3456/mp3:def.mp3/manifest.mpd"
      end
    end

    context 'with m4a audio' do
      let(:media_filename) { 'def.m4a' }

      it 'has the expected URL' do
        expect(stream.to_manifest_url).to eq "https://#{streaming_base_url}/ab/012/cd/3456/mp4:def.m4a/manifest.mpd"
      end
    end

    context 'with an unknown file type' do
      let(:media_filename) { 'def.xxx' }

      it 'returns nil' do
        expect(stream.to_manifest_url).to be_nil
      end
    end
  end
end
