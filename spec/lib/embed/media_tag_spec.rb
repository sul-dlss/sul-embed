# frozen_string_literal: true

require 'rails_helper'

describe Embed::MediaTag do
  include PurlFixtures

  subject { Capybara.string(subject_klass.to_html) }

  let(:purl) { video_purl }
  let(:viewer) do
    double(
      'MediaViewer',
      purl_object: Embed::Purl.new('druid'),
      body_height: '300'
    )
  end

  let(:subject_klass) { described_class.new(viewer) }

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
      expect(subject).to have_css('[data-src]', count: 3, visible: :all)
    end

    it 'includes a data attribute that includes the url to check the users auth status' do
      expect(subject).to have_css('video[data-auth-url]', count: 3, visible: :all)
      auth_url = subject.all('video[data-auth-url]', visible: :all).first['data-auth-url']
      expect(auth_url).to eq(Settings.streaming.auth_url)
    end

    it 'are not scrollable' do
      object = subject.find('[data-slider-object="0"]')

      expect(object['style']).not_to match(/overflow.*scroll/)
    end

    context 'single video' do
      let(:purl) { single_video_purl }

      it 'includes a 100% height attribute' do
        expect(subject).to have_css("video[height='100%']", visible: :all)
      end

      it 'shows location restricted messages to the screen reader' do
        expect(subject).to have_css('video[aria-labelledby="access-restricted-message-div-0"]', visible: :all)
        expect(subject).to have_css('div#access-restricted-message-div-0')
      end

      it 'shows a location restricted message in place of the video' do
        expect(subject).to have_css('.sul-embed-media-access-restricted .line1', text: 'Restricted media cannot be played in your location')
      end
    end

    context 'single video open to the world' do
      let(:purl) { video_purl_unrestricted }

      it 'does not show any location restricted messages' do
        expect(subject).not_to have_css('.sul-embed-media-access-restricted .line1', text: 'Restricted media cannot be played in your location')
      end
    end

    context 'file and object level thumbnails' do
      let(:purl) { file_and_object_level_thumb_purl }

      it 'has the correct number of objects (4)' do
        expect(subject).to have_css('[data-slider-object]', count: 4, visible: :all)
      end

      it 'does not include object level thumbnails' do
        expect(subject).to have_css('[data-file-label="audio.mp3"]', visible: :all)
        expect(subject).not_to have_css('[data-file-label="thumb.jp2"]', visible: :all)
      end

      it 'does not include file level thumbnails' do
        expect(subject).not_to have_css('[data-file-label="audio_1.jp2"]', visible: :all)
      end

      it 'includes the file level thumbnail data-attribute when present' do
        object = subject.find('[data-slider-object="1"]')
        expect(object['data-thumbnail-url']).to match(%r{%2Fvideo_1/square/75,75/})
      end

      it 'does not mistakenly use secondary files like jpgs as thumbnails' do
        object = subject.find('[data-slider-object="2"]')
        expect(object['data-thumbnail-url']).to be_blank
      end
    end

    context 'previewable files within media objects' do
      let(:purl) { video_purl_with_image }

      it 'are included as top level objects' do
        expect(subject).to have_css('div img.sul-embed-media-thumb')
      end

      it 'are scrollable' do
        object = subject.find('[data-slider-object="1"]')

        expect(object['style']).to include 'overflow-y: scroll'
      end
    end

    context 'video' do
      it 'renders a video tag in the provided document' do
        expect(subject).to have_css('video', visible: :all)
      end
    end

    describe 'poster' do
      context 'when a file level thumbnail is present' do
        let(:purl) { file_and_object_level_thumb_purl }

        it 'includes a poster attribute' do
          expect(subject).to have_css('video[poster]', visible: :all)
          video = subject.find('video[poster]', visible: :all)
          expect(video['poster']).to match(%r{/druid%2Fvideo_1/full/})
        end
      end

      context 'when the file-level thumbnail is downloadable' do
        let(:purl) { file_and_object_level_downloadable_thumb_purl }

        it 'uses a large thumbnail' do
          video = subject.find('video[poster]', visible: :all)
          expect(video['poster']).to match(%r{/full/!800,600/})
        end
      end

      context 'when a file level thumbnail is not present' do
        it 'does not include a poster attribute' do
          expect(subject).not_to have_css('video[poster]', visible: :all)
        end
      end
    end

    context 'audio' do
      let(:purl) { audio_purl }

      it 'renders an audo tag in the provided document' do
        expect(subject).to have_css('audio', visible: :all)
      end
    end
  end

  describe '#media_wrapper' do
    describe 'data-stanford-only attribute' do
      it 'true for Stanford only files' do
        resource_file = instance_double(Embed::Purl::ResourceFile, stanford_only?: true, location_restricted?: false, label: 'ignored', duration: nil)
        media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, file: resource_file))
        expect(media_wrapper).to have_css('[data-stanford-only="true"]')
      end

      it 'false for public files' do
        resource_file = instance_double(Embed::Purl::ResourceFile, stanford_only?: false, location_restricted?: false, label: 'ignored', duration: nil)
        media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, file: resource_file))
        expect(media_wrapper).to have_css('[data-stanford-only="false"]')
      end
    end

    describe 'duration' do
      it 'sets the duration when the resource file has duration' do
        resource_file = instance_double(Embed::Purl::ResourceFile, label: 'ignored', duration: '1:02')
        media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, file: resource_file))
        expect(media_wrapper).to have_css('[data-duration="1:02"]')
      end

      it 'leaves the duration empty when the resource file is missing duration' do
        resource_file = instance_double(Embed::Purl::ResourceFile, label: 'ignored', duration: nil)
        media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, file: resource_file))
        expect(media_wrapper).to have_css('[data-duration=""]')
      end
    end
    # TODO:  not sure if we're going to keep data-location-restricted as an attrib or just use element

    describe 'data-location-restricted attribute' do
      context 'stanford_only' do
        it 'true for location restricted files' do
          resource_file = instance_double(Embed::Purl::ResourceFile, stanford_only?: true, location_restricted?: true, label: 'ignored', duration: nil)
          media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, file: resource_file))
          expect(media_wrapper).to have_css('[data-location-restricted="true"]')
        end

        it 'false for public files' do
          resource_file = instance_double(Embed::Purl::ResourceFile, stanford_only?: true, location_restricted?: false, label: 'ignored', duration: nil)
          media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, file: resource_file))
          expect(media_wrapper).to have_css('[data-location-restricted="false"]')
        end
      end

      context 'not stanford_only' do
        it 'true for location restricted files' do
          resource_file = instance_double(Embed::Purl::ResourceFile, stanford_only?: false, location_restricted?: true, label: 'ignored', duration: nil)
          media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, file: resource_file))
          expect(media_wrapper).to have_css('[data-location-restricted="true"]')
        end

        it 'false for public files' do
          resource_file = instance_double(Embed::Purl::ResourceFile, stanford_only?: false, location_restricted?: false, label: 'ignored', duration: nil)
          media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, file: resource_file))
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
        expect(subject).to have_css('source[type="application/x-mpegURL"]', visible: :all)
      end
    end

    describe '#streaming_url_for' do
      it 'gets the correct URL based on the passed in type' do
        expect(subject_klass.send(:streaming_url_for, file, :hls)).to match(%r{.*/playlist.m3u8$})
        expect(subject_klass.send(:streaming_url_for, file, :dash)).to match(%r{.*/manifest.mpd$})
      end
    end

    describe '#previewable_element' do
      before { stub_purl_response_with_fixture(purl) }

      let(:previewable_element) { subject_klass.send(:previewable_element, double('file', label: 'abc123', title: 'abc123')) }

      it 'passes the square thumb url as a data attribute' do
        expect(previewable_element).to match(
          %r{data-thumbnail-url="https://stacks.*/iiif/.*abc123/square/75,75.*"}
        )
      end

      it 'includes an image element which points to a stacks 400px thumb' do
        expect(previewable_element).to match(/<img/)
        expect(previewable_element).to match(
          %r{src='https://stacks.*/iiif/.*abc123/full/!400,400.*'}
        )
      end

      it 'includes a class that indicates that there is are many media objects (to make room for the slider control)' do
        expect(previewable_element).to match(/class='.* sul-embed-many-media/)
      end
    end
  end
end
