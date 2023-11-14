# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Viewer::CommonViewer do
  include PurlFixtures

  let(:request) { Embed::Request.new({ url: 'http://purl.stanford.edu/abc123' }) }

  let(:file_viewer) { Embed::Viewer::File.new(request) }
  let(:geo_viewer) { Embed::Viewer::Geo.new(request) }
  let(:media_viewer) { Embed::Viewer::Media.new(request) }
  let(:was_seed_viewer) { Embed::Viewer::WasSeed.new(request) }

  before do
    stub_request(:get, 'https://purl.stanford.edu/12345.xml')
      .to_return(status: 200, body: multi_file_purl)
  end

  describe 'height/width' do
    it 'sets a default height and default width to nil (which can be overridden at the viewer level)' do
      stub_purl_request(request)
      expect(file_viewer.send(:default_width)).to be_nil
    end

    it 'uses the incoming maxheight/maxwidth parameters from the request' do
      expect(request).to receive(:maxheight).at_least(:once).and_return(100)
      expect(request).to receive(:maxwidth).at_least(:once).and_return(200)
      stub_purl_request(request)
      expect(file_viewer.height).to eq 100
      expect(file_viewer.width).to eq 200
    end
  end

  describe 'external_url' do
    it 'returns nil' do
      expect(request).to receive(:purl_object).and_return(nil)
      common_viewer = described_class.new(request)
      expect(common_viewer.external_url).to be_nil
    end
  end

  describe '#sul_pretty_date' do
    it 'parses a date into a standardized format' do
      expect(file_viewer.sul_pretty_date(Time.zone.now.to_s)).to match(/^\d{2}-\w{3}-\d{4}$/)
    end

    it 'checks for a blank string' do
      expect(file_viewer.sul_pretty_date(nil)).to be_nil
    end
  end

  describe '#show_download?' do
    it 'false for file viewers' do
      expect(file_viewer).not_to be_show_download
    end

    it 'true for image, geo and media viewer' do
      expect(geo_viewer).to be_show_download
      expect_any_instance_of(Embed::Purl).to receive(:downloadable_files).and_return(['a'])
      expect(media_viewer).to be_show_download
    end

    it 'false when hide_download is specified' do
      hide_request = Embed::Request.new(url: 'http://purl.stanford.edu/abc123',
                                        hide_download: 'true')
      geo_hide_viewer = Embed::Viewer::Geo.new(hide_request)
      expect(geo_hide_viewer).not_to be_show_download
    end
  end

  describe '#show_download_count?' do
    it 'true for non-image viewers' do
      expect(file_viewer).to be_show_download_count
      expect(geo_viewer).to be_show_download_count
      expect(media_viewer).to be_show_download_count
      expect(was_seed_viewer).to be_show_download_count
    end
  end

  describe '#iframe_title' do
    it 'determines the title from the class name' do
      expect(file_viewer.iframe_title).to eq 'File viewer'
    end
  end
end
