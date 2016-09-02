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
      expect(subject).to have_css('[data-src]', count: 2, visible: false)
    end

    it 'includes a data attribute that includes the url to check the users auth status' do
      expect(subject).to have_css('video[data-auth-url]', count: 2, visible: false)
      auth_url = subject.all('video[data-auth-url]', visible: false).first['data-auth-url']
      expect(auth_url).to match(%r{https?://stacks\.stanford\.edu.*/auth_check})
    end

    context 'single video' do
      let(:purl) { single_video_purl }
      it 'includes a height attribute equal to the body height' do
        expect(subject).to have_css("video[height='#{viewer.body_height}px']", visible: false)
      end

      it 'shows location restricted messages to the screen reader' do
        expect(subject).to have_css('video[aria-labelledby="access-restricted-message-div-0"]', visible: false)
        expect(subject).to have_css('div#access-restricted-message-div-0')
      end
    end

    context 'multiple videos' do
      it 'includes a height attribute equal to the body height minus some px to make way for the thumb slider' do
        expect(subject).to have_css('video[height="276px"]', visible: false)
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
        expect(subject).to have_css('video', visible: false)
      end
    end

    context 'audio' do
      let(:purl) { audio_purl }

      it 'renders an audo tag in the provided document' do
        expect(subject).to have_css('audio', visible: false)
      end
    end
  end

  describe '#media_wrapper' do
    describe 'data-stanford-only attribute' do
      it 'true for Stanford only files' do
        resource_file = double(Embed::PURL::Resource::ResourceFile, stanford_only?: true, location_restricted?: false)
        media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, label: 'ignored', file: resource_file))
        expect(media_wrapper).to have_css('[data-stanford-only="true"]')
      end

      it 'false for public files' do
        resource_file = double(Embed::PURL::Resource::ResourceFile, stanford_only?: false, location_restricted?: false)
        media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, label: 'ignored', file: resource_file))
        expect(media_wrapper).to have_css('[data-stanford-only="false"]')
      end
    end
    describe 'location restriction message' do
      it 'displayed when not in location' do
        resource_file = double(Embed::PURL::Resource::ResourceFile, stanford_only?: false, location_restricted?: true)
        media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, label: 'ignored', file: resource_file))
        expect(media_wrapper).to have_css('.sul-embed-media-access-restricted .line1', text: 'Restricted media cannot be played in your location')
        expect(media_wrapper).to have_css('.sul-embed-media-access-restricted .line2', text: 'See Access conditions for more information')
      end
      it 'not displayed when in location' do
        resource_file = double(Embed::PURL::Resource::ResourceFile, stanford_only?: false, location_restricted?: false)
        media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, label: 'ignored', file: resource_file))
        expect(media_wrapper).not_to have_css('.sul-embed-media-access-restricted')
        expect(media_wrapper).not_to have_css('.sul-embed-media-access-restricted .line1', text: 'Limited access for non-Stanford guests')
        expect(media_wrapper).not_to have_css('.sul-embed-media-access-restricted .line2', text: 'See Access conditions for more information')
      end
    end
    describe 'duration' do
      it 'sets the duration when the resource file has duration' do
        resource_file = double(Embed::PURL::Resource::ResourceFile, video_duration: Embed::PURL::Duration.new('PT0H1M2S'))
        media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, label: 'ignored', file: resource_file))
        expect(media_wrapper).to have_css('[data-duration="1:02"]')
      end
      it 'leaves the duration empty when the resource file is missing duration' do
        resource_file = double(Embed::PURL::Resource::ResourceFile)
        media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, label: 'ignored', file: resource_file))
        expect(media_wrapper).to have_css('[data-duration=""]')
      end
    end
    # TODO:  not sure if we're going to keep data-location-restricted as an attrib or just use element
    describe 'data-location-restricted attribute' do
      context 'stanford_only' do
        it 'true for location restricted files' do
          resource_file = double(Embed::PURL::Resource::ResourceFile, stanford_only?: true, location_restricted?: true)
          media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, label: 'ignored', file: resource_file))
          expect(media_wrapper).to have_css('[data-location-restricted="true"]')
        end

        it 'false for public files' do
          resource_file = double(Embed::PURL::Resource::ResourceFile, stanford_only?: true, location_restricted?: false)
          media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, label: 'ignored', file: resource_file))
          expect(media_wrapper).to have_css('[data-location-restricted="false"]')
        end
      end
      context 'not stanford_only' do
        it 'true for location restricted files' do
          resource_file = double(Embed::PURL::Resource::ResourceFile, stanford_only?: false, location_restricted?: true)
          media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, label: 'ignored', file: resource_file))
          expect(media_wrapper).to have_css('[data-location-restricted="true"]')
        end

        it 'false for public files' do
          resource_file = double(Embed::PURL::Resource::ResourceFile, stanford_only?: false, location_restricted?: false)
          media_wrapper = Capybara.string(subject_klass.send(:media_wrapper, label: 'ignored', file: resource_file))
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
        expect(subject).to have_css('source[type="application/x-mpegURL"]', visible: false)
      end
    end

    describe '#streaming_url_for' do
      it 'gets the correct URL based on the passed in type' do
        expect(subject_klass.send(:streaming_url_for, file, :hls)).to match(%r{.*/playlist.m3u8$})
        expect(subject_klass.send(:streaming_url_for, file, :dash)).to match(%r{.*/manifest.mpd$})
        expect(subject_klass.send(:streaming_url_for, file, :flash)).to match(%r{^rtmp://.*})
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

    describe '#media_element' do
      before { stub_purl_response_with_fixture(purl) }
      let(:media_file) { double('ResourceFile', title: 'media_file.mp4') }
      let(:media_thumb_file) { nil }
      let(:resource) { double('Resource', title: 'abc123.mp4', media_file: media_file, media_thumb: media_thumb_file, type: '_') }
      let(:media_element) { subject_klass.send(:media_element, 'Some Label', resource) }

      it 'includes id indicating the position of the resource in the slider' do
        expect(subject_klass).to receive(:media_wrapper).with(label: 'Some Label', file: media_file, thumbnail: nil).and_call_original

        expect(media_element).to match(/id="sul-embed-media-0"/)
      end

      context 'resource level thumbs' do
        let(:media_thumb_file) { double('ResourceFile', title: 'media_thumb.jp2') }

        it 'includes resource level thumbs where available' do
          expect(subject_klass).to receive(:stacks_square_url).with('druid', media_thumb_file.title, size: '75').and_return('thumb_url.jp2')
          expect(subject_klass).to receive(:stacks_thumb_url).with('druid', media_thumb_file.title).and_return('thumb_url.jp2')
          expect(subject_klass).to receive(:media_wrapper).with(label: 'Some Label', file: media_file, thumbnail: 'thumb_url.jp2').and_call_original

          expect(media_element).to match(/poster='thumb_url.jp2'/)
          expect(media_element).to match(/data-thumbnail-url="thumb_url.jp2"/)
        end
      end
    end
  end
end
