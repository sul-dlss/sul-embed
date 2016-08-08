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
      expect(body_html).to have_css('video')
    end
  end

  describe '#download_html' do
    before { stub_purl_response_with_fixture(video_purl) }
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
  end
end
