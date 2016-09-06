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
    let(:purl) { video_purl }
    before { stub_purl_response_with_fixture(purl) }
    let(:download_html) { Capybara.string(media_viewer.download_html.to_str) }

    it 'uses the label as the link text when present' do
      expect(download_html).to have_css('li a', text: 'Download Transcript', visible: false)
      expect(download_html).not_to have_css('li a', text: 'Download abc_123_script.pdf', visible: false)
    end

    it 'uses the file id as the link text when no label present' do
      expect(download_html).to have_css('li a', text: 'Download abc_123.mp4', visible: false)
    end

    it 'includes the file sizes when present' do
      expect(download_html).to have_css('li', text: /\(\d+\.\d+ MB\)/, visible: false)
      expect(download_html).to have_css('li', text: /\(\d+\.\d+ kB\)/, visible: false)
    end

    it 'includes attributes appropriate for _blank target download links' do
      expect(download_html).to have_css('li a[target="_blank"][rel="noopener noreferrer"]', count: 3, visible: false)
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

      it 'has a span with the location restricted message' do
        expect(download_html).to have_css('.sul-embed-location-restricted-text', text: '(Restricted)', visible: false)
      end
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
end
