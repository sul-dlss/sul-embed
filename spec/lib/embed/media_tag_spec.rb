require 'rails_helper'

describe Embed::MediaTag do
  include PURLFixtures

  let(:purl) { video_purl }
  let(:viewer) do
    double(
      'MediaViewer',
      purl_object: Embed::PURL.new('druid'),
      body_height: '300'
    )
  end

  let(:subject_klass) { described_class.new(viewer) }

  subject { Capybara.string(subject_klass.to_html) }

  describe 'media tags' do
    before { stub_purl_response_with_fixture(purl) }

    it 'includes the file label as a data attribute' do
      expect(subject).to have_css('[data-file-label="abc_123.mp4"]')
      expect(subject).to have_css('[data-file-label="Second Video"]')
    end

    it 'includes a data attribute for the thumb-slider bar' do
      expect(subject).to have_css('[data-slider-object="0"]')
      expect(subject).to have_css('[data-slider-object="1"]')
    end

    it 'includes a data-src attribute for the dash player' do
      expect(subject).to have_css('[data-src]', count: 2)
    end

    it 'includes a data attribute that includes the url to check the users auth status' do
      expect(subject).to have_css('video[data-auth-url]', count: 2)
      auth_url = subject.all('video[data-auth-url]').first['data-auth-url']
      expect(auth_url).to match(%r{https?://stacks\.stanford\.edu.*/auth_check})
    end

    it 'includes a height attribute equal to the body height minus some px to make way for the thumb slider' do
      expect(subject).to have_css('video[height="276px"]')
    end

    context 'video' do
      it 'renders a video tag in the provided document' do
        expect(subject).to have_css('video')
      end
    end

    context 'audio' do
      let(:purl) { audio_purl }

      it 'renders an audo tag in the provided document' do
        expect(subject).to have_css('audio')
      end
    end
  end

  describe 'private methods' do
    let(:file) { double('File', title: 'abc123.mp4') }
    describe '#enabled_streaming_sources' do
      before { stub_purl_response_with_fixture(purl) }
      it 'adds a source element for every enabled type' do
        expect(subject).to have_css('source[type="application/x-mpegURL"]')
      end
    end

    describe '#streaming_url_for' do
      it 'appends the generated stream URL with the appropriate suffix' do
        expect(subject_klass.send(:streaming_url_for, file, :hls)).to match(%r{.*/stream.m3u8$})
        expect(subject_klass.send(:streaming_url_for, file, :dash)).to match(%r{.*/stream.mpd$})
      end

      it 'has the appropriate Media Stacks URL with druid and filename' do
        expect(subject_klass.send(:streaming_url_for, file, :hls)).to match(%r{stacks\.stanford\.edu/media/druid/abc123\.mp4/stream.m3u8})
      end
    end
  end
end
