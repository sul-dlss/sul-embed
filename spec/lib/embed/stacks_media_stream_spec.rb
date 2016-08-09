require 'rails_helper'

describe Embed::StacksMediaStream do
  let(:streaming_base_url) { Settings.stream.url }

  describe '#to_playlist_url' do
    context 'video' do
      it 'mp4 extension' do
        sms = described_class.new(druid: 'ab012cd3456', file_name: 'def.mp4')
        expect(sms.to_playlist_url).to eq "#{streaming_base_url}/ab/012/cd/3456/mp4:def.mp4/playlist.m3u8"
      end
      it 'mov extension' do
        sms = described_class.new(druid: 'ab012cd3456', file_name: 'def.mov')
        expect(sms.to_playlist_url).to eq "#{streaming_base_url}/ab/012/cd/3456/mp4:def.mov/playlist.m3u8"
      end
    end
    it 'audio - mp3' do
      sms = described_class.new(druid: 'ab012cd3456', file_name: 'def.mp3')
      expect(sms.to_playlist_url).to eq "#{streaming_base_url}/ab/012/cd/3456/mp3:def.mp3/playlist.m3u8"
    end
    it 'unknown' do
      sms = described_class.new(druid: 'ab012cd3456', file_name: 'def.xxx')
      expect(sms.to_playlist_url).to be_nil
    end
  end

  describe '#to_manifest_url' do
    context 'video' do
      it 'mp4 extension' do
        sms = described_class.new(druid: 'ab012cd3456', file_name: 'def.mp4')
        expect(sms.to_manifest_url).to eq "#{streaming_base_url}/ab/012/cd/3456/mp4:def.mp4/manifest.mpd"
      end
      it 'mov extension' do
        sms = described_class.new(druid: 'ab012cd3456', file_name: 'def.mov')
        expect(sms.to_manifest_url).to eq "#{streaming_base_url}/ab/012/cd/3456/mp4:def.mov/manifest.mpd"
      end
    end
    it 'audio - mp3' do
      sms = described_class.new(druid: 'ab012cd3456', file_name: 'def.mp3')
      expect(sms.to_manifest_url).to eq "#{streaming_base_url}/ab/012/cd/3456/mp3:def.mp3/manifest.mpd"
    end
    it 'unknown' do
      sms = described_class.new(druid: 'ab012cd3456', file_name: 'def.xxx')
      expect(sms.to_manifest_url).to be_nil
    end
  end
end
