require 'rails_helper'

describe Embed::Viewer::Media do
  include PURLFixtures

  let(:request) { Embed::Request.new(url: 'https://purl.stanford.edu/ignored') }
  let(:media_viewer) { Embed::Viewer::Media.new(request) }

  describe 'Supported types' do
    it 'is an empty array when Settings.enable_media_viewer? is false' do
      expect(Settings).to receive(:enable_media_viewer?).and_return(false)
      expect(described_class.supported_types).to eq([])
    end

    it 'is an array of only media when Settings.enable_media_viewer? is true' do
      expect(Settings).to receive(:enable_media_viewer?).and_return(true)
      expect(described_class.supported_types).to eq([:media])
    end
  end

  describe '#body_html' do
    before { stub_purl_response_with_fixture(video_purl) }
    it 'implements the MediaTag class appropriately and gets a video tag' do
      allow(request).to receive(:rails_request).and_return(double(host_with_port: ''))
      stub_request(request)
      body_html = Capybara.string(media_viewer.body_html)
      expect(body_html).to have_css('video', visible: false)
    end
  end

  describe 'media tag' do
    before { stub_purl_response_with_fixture(video_with_spaces_in_filename_purl) }
    it 'does not do URL escaping on sources' do
      allow(request).to receive(:rails_request).and_return(double(host_with_port: ''))
      stub_request(request)
      source = Capybara.string(media_viewer.body_html).all('video source', visible: false).first
      expect(source['src']).not_to include('%20')
      expect(source['src']).not_to include('&amp;')
    end
  end

  describe '#download_html' do
    it 'empty string when show_download? is false' do
      expect(media_viewer).to receive(:show_download?).and_return false
      expect(media_viewer.download_html).to eq ''
    end
    context 'when downloadable files' do
      let(:purl) { video_purl }
      before { stub_purl_response_with_fixture(purl) }
      let(:download_html) { Capybara.string(media_viewer.download_html.to_str) }

      it 'uses the label as the link text when present' do
        expect(download_html).to have_css('li a', text: 'Download Transcript', visible: false)
        expect(download_html).not_to have_css('li a', text: 'Download abc_123_script.pdf', visible: false)
      end

      it 'uses the file id as the link text when no label present' do
        expect(download_html).to have_css('li a', text: 'Download abc_333.mp4', visible: false)
      end

      it 'includes the file sizes when present' do
        expect(download_html).to have_css('li', text: /\(\d+\.\d+ MB\)/, visible: false)
        expect(download_html).to have_css('li', text: /\(\d+\.\d+ kB\)/, visible: false)
      end

      it 'includes attributes appropriate for _blank target download links' do
        expect(download_html).to have_css('li a[target="_blank"][rel="noopener noreferrer"]', count: 3, visible: false)
      end

      it 'includes downloadable files' do
        expect(download_html).to have_content 'Download item'
        expect(download_html).to have_content 'Download Second Video'
        expect(download_html).to have_content 'Download Transcript'
      end

      it 'does not include files with no-download rule' do
        expect(download_html).not_to have_content('Download Tape 1')
      end

      it 'does not include files with read location restricted' do
        expect(download_html).not_to have_content 'Download abc_123.mp4'
      end

      context 'Stanford only' do
        let(:purl) { stanford_restricted_file_purl }

        it 'has a span with a stanford-only s icon class (with screen-reader text)' do
          expect(download_html).to have_css('.sul-embed-stanford-only-text', visible: false)
          expect(download_html).to have_css('.sul-embed-text-hide', text: 'Stanford only', visible: false)
        end
      end

      context 'Location restricted' do
        let(:purl) { single_video_purl }

        it 'not included in download panel' do
          expect(media_viewer.download_html).to eq ''
        end
      end
    end
  end

  context '#download_list_items' do
    context '(non-empty)' do
      let(:dli) do
        stub_purl_response_with_fixture(video_purl)
        media_viewer.send(:download_list_items)
      end
      it 'includes downloadable files' do
        expect(dli).to match 'Download Second Video'
        expect(dli).to match 'Download Transcript'
      end
      it 'does not include non-downloadable files' do
        expect(dli).not_to match 'Download Tape 1'
      end
      it 'does not include location restricted files (read access)' do
        expect(dli).not_to match 'Download abc_123.mp4'
      end
    end
    it 'empty string when no downloadable files' do
      my_purl_obj = double(Embed::PURL, downloadable_files: [])
      my_req = double(Embed::Request, purl_object: my_purl_obj)
      my_media_viewer = Embed::Viewer::Media.new(my_req)
      my_dli = my_media_viewer.send(:download_list_items)
      expect(my_dli).to eq ''
    end
  end

  describe '#metadata_html' do
    before { stub_purl_response_with_fixture(video_purl) }
    let(:metadata_html) { Capybara.string(media_viewer.metadata_html.to_str) }

    it 'includes a media accessibility note' do
      expect(metadata_html).to have_css('dt', text: 'Media accessibility', visible: false)
      expect(metadata_html).to have_css(
        'dd',
        text: /A transcript may be available in the Download panel/,
        visible: false
      )
    end

    it 'links to the feedback address' do
      link = metadata_html.find('a', text: Settings.purl_feedback_email, visible: false)
      expect(link['href']).to eq "mailto:#{Settings.purl_feedback_email}"
    end
  end

  describe '#show_download?' do
    it 'false when downloadable file count is 0' do
      my_purl_obj = double(Embed::PURL, downloadable_files: [])
      my_req = double(Embed::Request, purl_object: my_purl_obj, hide_download?: false)
      my_media_viewer = Embed::Viewer::Media.new(my_req)
      expect(my_media_viewer.show_download?).to be false
    end
    it 'true when downloadable file count is non-zero' do
      my_purl_obj = double(Embed::PURL, downloadable_files: ['a'])
      my_req = double(Embed::Request, purl_object: my_purl_obj, hide_download?: false)
      my_media_viewer = Embed::Viewer::Media.new(my_req)
      expect(my_media_viewer.show_download?).to be true
    end
    it 'false when request hide_download? is true' do
      my_purl_obj = double(Embed::PURL, downloadable_files: ['a'])
      my_req = double(Embed::Request, purl_object: my_purl_obj, hide_download?: true)
      my_media_viewer = Embed::Viewer::Media.new(my_req)
      expect(my_media_viewer.show_download?).to be false
    end
  end
end
