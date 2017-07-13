require 'rails_helper'

describe Embed::Viewer::ImageX do
  include PURLFixtures
  let(:request) { Embed::Request.new(url: 'https://purl.stanford.edu/abc123') }
  let(:image_x_viewer) { Embed::Viewer::ImageX.new(request) }

  describe 'initialize' do
    it 'should be an Embed::Viewer::ImageX' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(image_x_viewer).to be_an Embed::Viewer::ImageX
    end
  end
  describe 'self.supported_types' do
    it 'should return an array of supported types' do
      expect(Embed::Viewer::ImageX.supported_types).to eq [:image, :manuscript, :map, :book]
    end
  end
  describe 'self.show_download_count?' do
    it 'should return false' do
      expect(Embed::Viewer::ImageX.show_download_count?).to be_falsey
    end
  end

  describe 'private methods' do
    describe '#drag_and_drop_url' do
      it 'links to a PURL with a manifest parameter' do
        url = image_x_viewer.send(:drag_and_drop_url)
        purl = 'https://purl.stanford.edu/abc123'
        expect(url).to match(%r{^#{purl}\?manifest=#{purl}/iiif/manifest$})
      end
    end
  end
end
