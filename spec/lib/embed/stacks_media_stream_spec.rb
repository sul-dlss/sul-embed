# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::StacksMediaStream do
  let(:streaming_base_url) { Settings.stream.url }

  describe '#to_thumbnail_url' do
    let(:stream) { described_class.new(druid: 'ab012cd3456', file:) }

    context 'when file has a world-downloadable thumbnail' do
      let(:file) { instance_double(Embed::Purl::ResourceFile, title: 'def.mp4', thumbnail:) }
      let(:thumbnail) { instance_double(Embed::Purl::ResourceFile, title: 'thumb.jp2', world_downloadable?: true) }

      it 'uses a high-resolution thumbnail' do
        expect(stream.to_thumbnail_url).to match(%r{ab012cd3456%2Fthumb/full/!800,600})
      end
    end

    context 'when file has a non-world-downloadable thumbnail' do
      let(:file) { instance_double(Embed::Purl::ResourceFile, title: 'def.mp4', thumbnail:) }
      let(:thumbnail) { instance_double(Embed::Purl::ResourceFile, title: 'thumb.jp2', world_downloadable?: false) }

      it 'uses a standard thumbnail' do
        expect(stream.to_thumbnail_url).to match(%r{ab012cd3456%2Fthumb/full/!400,400})
      end
    end

    context 'when file has no thumbnail' do
      context 'when file is audio' do
        let(:file) { instance_double(Embed::Purl::ResourceFile, title: 'def.m4a', thumbnail:) }
        let(:thumbnail) { nil }

        it 'uses the default audio thumbnail' do
          expect(stream.to_thumbnail_url).to match(/waveform-audio-poster/)
        end
      end

      context 'when file is not audio' do
        let(:file) { instance_double(Embed::Purl::ResourceFile, title: 'def.mp4', thumbnail:) }
        let(:thumbnail) { nil }

        it 'returns nil' do
          expect(stream.to_thumbnail_url).to be_nil
        end
      end
    end
  end

  describe '#to_playlist_url' do
    context 'video' do
      it 'mp4 extension' do
        sms = described_class.new(druid: 'ab012cd3456', file: instance_double(Embed::Purl::ResourceFile, title: 'def.mp4'))
        expect(sms.to_playlist_url).to eq "https://#{streaming_base_url}/ab/012/cd/3456/mp4:def.mp4/playlist.m3u8"
      end

      it 'mov extension' do
        sms = described_class.new(druid: 'ab012cd3456', file: instance_double(Embed::Purl::ResourceFile, title: 'def.mov'))
        expect(sms.to_playlist_url).to eq "https://#{streaming_base_url}/ab/012/cd/3456/mp4:def.mov/playlist.m3u8"
      end
    end

    it 'audio - mp3' do
      sms = described_class.new(druid: 'ab012cd3456', file: instance_double(Embed::Purl::ResourceFile, title: 'def.mp3'))
      expect(sms.to_playlist_url).to eq "https://#{streaming_base_url}/ab/012/cd/3456/mp3:def.mp3/playlist.m3u8"
    end

    it 'unknown' do
      sms = described_class.new(druid: 'ab012cd3456', file: instance_double(Embed::Purl::ResourceFile, title: 'def.xxx'))
      expect(sms.to_playlist_url).to be_nil
    end
  end

  describe '#to_manifest_url' do
    context 'video' do
      it 'mp4 extension' do
        sms = described_class.new(druid: 'ab012cd3456', file: instance_double(Embed::Purl::ResourceFile, title: 'def.mp4'))
        expect(sms.to_manifest_url).to eq "https://#{streaming_base_url}/ab/012/cd/3456/mp4:def.mp4/manifest.mpd"
      end

      it 'mov extension' do
        sms = described_class.new(druid: 'ab012cd3456', file: instance_double(Embed::Purl::ResourceFile, title: 'def.mov'))
        expect(sms.to_manifest_url).to eq "https://#{streaming_base_url}/ab/012/cd/3456/mp4:def.mov/manifest.mpd"
      end
    end

    it 'audio - mp3' do
      sms = described_class.new(druid: 'ab012cd3456', file: instance_double(Embed::Purl::ResourceFile, title: 'def.mp3'))
      expect(sms.to_manifest_url).to eq "https://#{streaming_base_url}/ab/012/cd/3456/mp3:def.mp3/manifest.mpd"
    end

    it 'audio - m4a' do
      sms = described_class.new(druid: 'ab012cd3456', file: instance_double(Embed::Purl::ResourceFile, title: 'def.m4a'))
      expect(sms.to_manifest_url).to eq "https://#{streaming_base_url}/ab/012/cd/3456/mp4:def.m4a/manifest.mpd"
    end

    it 'unknown' do
      sms = described_class.new(druid: 'ab012cd3456', file: instance_double(Embed::Purl::ResourceFile, title: 'def.xxx'))
      expect(sms.to_manifest_url).to be_nil
    end
  end
end
