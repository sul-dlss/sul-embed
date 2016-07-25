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

    context 'single video' do
      let(:purl) { single_video_purl }
      it 'includes a height attribute equal to the body height' do
        expect(subject).to have_css("video[height='#{viewer.body_height}px']")
      end
    end

    context 'multiple videos' do
      it 'includes a height attribute equal to the body height minus some px to make way for the thumb slider' do
        expect(subject).to have_css('video[height="276px"]')
      end
    end

    context 'previewable files withing media objects' do
      let(:purl) { video_purl_with_image }
      it 'are included as top level objects' do
        expect(subject).to have_css('div img.sul-embed-media-thumb')
      end
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

  describe '#media_wrapper' do
    describe 'data-stanford-only attribute' do
      it 'true for Stanford only files' do
        media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, label: 'ignored', stanford_only: true, location_restricted: false))
        expect(media_wrapper).to have_css('[data-stanford-only="true"]')
      end

      it 'false for public files' do
        media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, label: 'ignored', stanford_only: false, location_restricted: false))
        expect(media_wrapper).to have_css('[data-stanford-only="false"]')
      end
    end
    describe 'location restriction message' do
      it 'displayed when not in location' do
        media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, label: 'ignored', stanford_only: false, location_restricted: true))
        expect(media_wrapper).to have_css('.sul-embed-media-access-restricted .line1', text: 'Restricted media cannot be played in your location')
        expect(media_wrapper).to have_css('.sul-embed-media-access-restricted .line2', text: 'See Access conditions for more information')
      end
      it 'not displayed when in location' do
        media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, label: 'ignored', stanford_only: false, location_restricted: false))
        expect(media_wrapper).not_to have_css('.sul-embed-media-access-restricted')
        expect(media_wrapper).not_to have_css('.sul-embed-media-access-restricted .line1', text: 'Limited access for non-Stanford guests')
        expect(media_wrapper).not_to have_css('.sul-embed-media-access-restricted .line2', text: 'See Access conditions for more information')
      end
    end
    # TODO:  not sure if we're going to keep data-location-restricted as an attrib or just use element
    describe 'data-location-restricted attribute' do
      context 'stanford_only' do
        it 'true for location restricted files' do
          media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, label: 'ignored', stanford_only: true, location_restricted: true))
          expect(media_wrapper).to have_css('[data-location-restricted="true"]')
        end

        it 'false for public files' do
          media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, label: 'ignored', stanford_only: true, location_restricted: false))
          expect(media_wrapper).to have_css('[data-location-restricted="false"]')
        end
      end
      context 'not stanford_only' do
        it 'true for location restricted files' do
          media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, label: 'ignored', stanford_only: false, location_restricted: true))
          expect(media_wrapper).to have_css('[data-location-restricted="true"]')
        end

        it 'false for public files' do
          media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, label: 'ignored', stanford_only: false, location_restricted: false))
          expect(media_wrapper).to have_css('[data-location-restricted="false"]')
        end
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

    describe '#previewable_element' do
      before { stub_purl_response_with_fixture(purl) }
      let(:previewable_element) { subject_klass.send(:previewable_element, 'Some Label', file) }
      it 'passes the square thumb url as a data attribute' do
        expect(previewable_element).to match(
          %r{data-thumbnail-url="https://stacks.*/iiif/.*abc123/square/75,75.*"}
        )
      end

      it 'includes an image element which points to a stacks 400px thumb' do
        expect(previewable_element).to match(/<img/)
        expect(previewable_element).to match(
          %r{src='https://stacks.*/iiif/.*abc123/full/\!400,400.*'}
        )
      end

      it 'defines a max-height on the image that is equal to the viewer body height' do
        expect(previewable_element).to match(/style='max-height: 276px'/)
      end

      it 'includes a class that indicates that there is are many media objects (to make room for the slider control)' do
        expect(previewable_element).to match(/class='.* sul-embed-many-media/)
      end
    end
  end
end
