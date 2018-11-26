# frozen_string_literal: true

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
