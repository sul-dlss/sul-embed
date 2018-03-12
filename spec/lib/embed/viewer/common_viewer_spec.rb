require 'rails_helper'

describe Embed::Viewer::CommonViewer do
  include PURLFixtures
  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:file_viewer) { Embed::Viewer::File.new(request) }
  let(:geo_viewer) { Embed::Viewer::Geo.new(request) }
  let(:media_viewer) { Embed::Viewer::Media.new(request) }
  let(:was_seed_viewer) { Embed::Viewer::WasSeed.new(request) }

  describe 'height/width' do
    it 'sets a default height and default width to nil (which can be overridden at the viewer level)' do
      stub_request(request)
      expect(file_viewer.send(:default_width)).to be_nil
    end
    it 'uses the incoming maxheight/maxwidth parameters from the request' do
      expect(request).to receive(:maxheight).at_least(:once).and_return(100)
      expect(request).to receive(:maxwidth).at_least(:once).and_return(200)
      stub_request(request)
      expect(file_viewer.height).to eq 100
      expect(file_viewer.width).to eq 200
    end
  end
  describe 'external_url' do
    it 'returns nil' do
      expect(request).to receive(:purl_object).and_return(nil)
      common_viewer = Embed::Viewer::CommonViewer.new(request)
      expect(common_viewer.external_url).to be_nil
    end
  end
  describe '#file_url' do
    it 'creates a stacks file url' do
      expect(file_viewer.file_url('cool_file')).to eq 'https://stacks.stanford.edu/file/druid:abc123/cool_file'
    end
    it 'adds a download param' do
      expect(file_viewer.file_url('cool_file', download: true)).to eq 'https://stacks.stanford.edu/file/druid:abc123/cool_file?download=true'
    end
    it 'escapes special characters in the file' do
      expect(file_viewer.file_url('[Dissertation] micro-TEC vfinal (for submission)-augmented.pdf')).to eq 'https://stacks.stanford.edu/file/druid:abc123/%5BDissertation%5D%20micro-TEC%20vfinal%20%28for%20submission%29-augmented.pdf'
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
      expect(file_viewer.show_download?).to be_falsey
    end
    it 'true for image, geo and media viewer' do
      expect(geo_viewer.show_download?).to be_truthy
      expect_any_instance_of(Embed::PURL).to receive(:downloadable_files).and_return(['a'])
      expect(media_viewer.show_download?).to be_truthy
    end
    it 'false when hide_download is specified' do
      hide_request = Embed::Request.new(url: 'http://purl.stanford.edu/abc123',
                                        hide_download: 'true')
      geo_hide_viewer = Embed::Viewer::Geo.new(hide_request)
      expect(geo_hide_viewer.show_download?).to be_falsey
    end
  end
  describe '#show_download_count?' do
    it 'true for non-image viewers' do
      expect(file_viewer.show_download_count?).to be_truthy
      expect(geo_viewer.show_download_count?).to be_truthy
      expect(media_viewer.show_download_count?).to be_truthy
      expect(was_seed_viewer.show_download_count?).to be_truthy
    end
  end

  describe '#body_height' do
    it 'is the default_body_height when no maxheight is provided' do
      expect(file_viewer).to receive(:default_body_height).and_return(200)
      expect(file_viewer.body_height).to eq 200
    end

    it 'subtracts the header and footer height' do
      expect(request).to receive(:maxheight).at_least(:once).and_return(200)
      expect(file_viewer.body_height).to be < 200
    end
  end
end
