# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Viewer::CommonViewer do
  let(:request) { Embed::Request.new({ url: 'http://purl.stanford.edu/abc123' }) }

  let(:file_viewer) { Embed::Viewer::File.new(request) }
  let(:geo_viewer) { Embed::Viewer::Geo.new(request) }
  let(:media_viewer) { Embed::Viewer::Media.new(request) }
  let(:was_seed_viewer) { Embed::Viewer::WasSeed.new(request) }
  let(:purl) { build(:purl) }

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
  end

  describe 'height/width' do
    it 'uses the incoming maxheight/maxwidth parameters from the request' do
      expect(request).to receive(:maxheight).at_least(:once).and_return('100px')
      expect(request).to receive(:maxwidth).at_least(:once).and_return('200px')
      expect(file_viewer.height).to eq '100px'
      expect(file_viewer.width).to eq '200px'
    end
  end

  describe 'external_url' do
    it 'returns nil' do
      common_viewer = described_class.new(request)
      expect(common_viewer.external_url).to be_nil
    end
  end

  describe '#show_download?' do
    it 'false for file viewers' do
      expect(file_viewer).not_to be_show_download
    end

    it 'true for geo viewers' do
      expect(geo_viewer).to be_show_download
    end

    context 'when hide_download is specified' do
      let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123', hide_download: 'true') }

      it 'false when hide_download is specified' do
        geo_hide_viewer = Embed::Viewer::Geo.new(request)
        expect(geo_hide_viewer).not_to be_show_download
      end
    end
  end

  describe '#iframe_title' do
    let(:purl) { build(:purl, title: 'my title') }

    it 'determines the title from the class name' do
      expect(file_viewer.iframe_title).to eq 'File viewer: my title'
    end
  end

  describe '#any_stanford_only_files' do
    subject { file_viewer.any_stanford_only_files? }

    before do
      allow(Embed::Purl).to receive(:find).and_return(purl)
    end

    let(:purl) { build(:purl) }

    context 'when one or more files are stanford only' do
      let(:purl) do
        build(:purl, contents: [build(:resource, :file, files: [build(:resource_file, :stanford_only)])])
      end

      it { is_expected.to be true }
    end

    context 'when no files are stanford only' do
      let(:purl) do
        build(:purl, contents: [build(:resource, :file, files: [build(:resource_file)])])
      end

      it { is_expected.to be false }
    end
  end

  describe '#download_url' do
    subject { file_viewer.download_url }

    it { is_expected.to eq 'https://stacks.stanford.edu/object/abc123' }
  end

  context 'when a version_id is provided by purl' do
    subject { file_viewer.download_url }

    let(:request) do
      Embed::Request.new(url: 'http://purl.stanford.edu/bc123df456/version/1')
    end
    let(:purl) { build(:purl, contents: resources, druid: 'bc123df456', version_id: '1') }
    let(:resources) { [build(:resource, :file, druid: 'bc123df456', files: [build(:resource_file, label: 'A File')])] }

    it { is_expected.to eq 'https://stacks.stanford.edu/object/bc123df456/version/1' }
  end
end
