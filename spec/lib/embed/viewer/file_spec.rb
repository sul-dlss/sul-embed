require 'rails_helper'

describe Embed::Viewer::File do
  include PURLFixtures
  let(:purl_object) { double('purl_object') }
  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:file_viewer) { Embed::Viewer::File.new(request) }
  describe 'initialize' do
    it 'creates Embed::Viewer::File' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(file_viewer).to be_an Embed::Viewer::File
    end
  end
  describe 'self.default_viewer?' do
    it 'returns true' do
      expect(Embed::Viewer::File.default_viewer?).to be_truthy
    end
  end
  describe 'self.supported_types' do
    it 'returns an array of supported types' do
      expect(Embed::Viewer::File.supported_types).to eq [:file]
    end
  end
  describe 'body_height' do
    it 'defaults to 400 minus the footer and header height' do
      stub_purl_response_and_request(multi_resource_multi_type_purl, request)
      expect(file_viewer.send(:body_height)).to eq 307
    end

    it 'consumer requested maxheight minus the header/footer height' do
      height_request = Embed::Request.new(url: 'http://purl.stanford.edu/abc123', maxheight: '500')
      stub_request(height_request)
      viewer = Embed::Viewer::File.new(height_request)
      expect(viewer.send(:body_height)).to eq 407
    end

    it 'reduces the height based on the number of files in the object (1 file)' do
      stub_purl_response_and_request(file_purl, request)
      expect(file_viewer.send(:body_height)).to eq 107
    end

    it 'reduces the height based on the number of files in the object (2 files)' do
      stub_purl_response_and_request(image_purl, request)
      expect(file_viewer.send(:body_height)).to eq 182
    end
  end
  describe 'header tools' do
    it 'includes the search in the header tools' do
      stub_request(request)
      expect(file_viewer.send(:header_tools_logic)).to include(:file_search_logic)
    end
  end

  describe 'file_type_icon' do
    it 'default file icon if mimetype is not recognized' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(file_viewer.file_type_icon('application/null')).to eq 'sul-i-file-new-1'
    end
    it 'translated file icon for recognized mime type' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(file_viewer.file_type_icon('application/zip')).to eq 'sul-i-file-zipped'
    end
  end
end
