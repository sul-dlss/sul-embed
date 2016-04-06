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
end
