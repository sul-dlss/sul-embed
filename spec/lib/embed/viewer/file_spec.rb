require 'rails_helper'

describe Embed::Viewer::File do
  include PURLFixtures
  let(:purl_object) { double('purl_object') }
  let(:request) { double('request') }
  let(:file_viewer) { Embed::Viewer::File.new(request) }
  describe 'initialize' do
    it 'should be an Embed::Viewer::File' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(file_viewer).to be_an Embed::Viewer::File
    end
  end
  describe 'self.default_viewer?' do
    it 'should return true' do
      expect(Embed::Viewer::File.default_viewer?).to be_truthy
    end
  end
  describe 'self.supported_types' do
    it 'should return an array of supported types' do
      expect(Embed::Viewer::File.supported_types).to eq [:media]
    end
  end
  describe 'width' do
    it 'should return a width' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(file_viewer.width).to_not be nil
    end
  end
  describe 'height' do
    it 'should return a height' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(file_viewer.height).to_not be nil
    end
  end
  describe 'body_html' do
    it 'should return a table of files' do
      stub_purl_response_and_request(multi_resource_multi_file_purl, request)
      expect(file_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')
      html = Capybara.string(file_viewer.to_html)
      expect(html).to have_css '.sul-embed-file-list'
    end
  end
  describe 'file_type_icon' do
    it 'should return default file icon if mimetype is not recognized' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(file_viewer.file_type_icon('application/null')).to eq 'fa-file-o'
    end
    it 'should return translated file icon for recognized mime type' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(file_viewer.file_type_icon('application/zip')).to eq 'fa-file-archive-o'
    end
  end
end
