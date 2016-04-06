require 'rails_helper'

describe Embed::MediaTag do
  include PURLFixtures

  let(:purl) { video_purl }
  let(:viewer) do
    double(
      'MediaViewer',
      purl_object: Embed::PURL.new('ignored'),
      body_height: '300'
    )
  end
  let(:document) { double('Nokogiri HTML Builder') }
  subject { described_class.new(document, viewer) }

  before { stub_purl_response_with_fixture(purl) }

  describe 'media tags' do
    context 'video' do
      it 'renders a video tag in the provided document' do
        expect(document).to receive(:video)
        subject
      end
    end

    context 'audio' do
      let(:purl) { audio_purl }

      it 'renders an audo tag in the provided document' do
        expect(document).to receive(:audio)
        subject
      end
    end
  end

  describe 'private methods' do
    before { expect(document).to receive(:video) }
    let(:file) { double('File', title: 'abc123.mp4', mimetype: 'video/mp4') }
    describe '#enabled_streaming_sources' do
      it 'adds a source element for every enabled type' do
        expect(document).to receive(:source).with(hash_including(:src, type: 'video/mp4'))
        subject.send(:enabled_streaming_sources, file)
      end
    end

    describe '#streaming_url_for' do
      it 'wraps the generated stream URL with the protocol and suffix' do
        expect(subject.send(:streaming_url_for, file, :hls)).to match(%r{http://.*/playlist.m3u8})
        expect(subject.send(:streaming_url_for, file, :mdash)).to match(%r{http://.*/manifest.mpd})
      end
    end

    describe '#streaming_url_file_segment' do
      it 'is the filename with the extension appended with a ":"' do
        expect(subject.send(:streaming_url_file_segment, file)).to eq 'mp4:abc123.mp4'
      end
    end
  end
end
