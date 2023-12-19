# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::StacksMediaStream do
  subject(:stream) { described_class.new(druid: 'ab012cd3456', file:) }

  let(:file) { instance_double(Embed::Purl::ResourceFile, title: media_filename) }
  let(:media_filename) { 'def.mp4' }
  let(:streaming_base_url) { Settings.stream.url }

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
end
