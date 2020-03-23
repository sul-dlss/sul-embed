# frozen_string_literal: true

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

  describe 'self.supported_types' do
    it 'returns an array of supported types' do
      expect(Embed::Viewer::File.supported_types).to eq [:file]
    end
  end
  describe 'default_height' do
    context 'when title and search is hidden' do
      before do
        expect(request).to receive(:hide_title?).at_least(:once).and_return(true)
        expect(request).to receive(:hide_search?).at_least(:once).and_return(true)
      end

      it 'defaults to 400' do
        stub_purl_response_and_request(multi_resource_multi_type_purl, request)
        expect(file_viewer.send(:default_height)).to eq 330
      end

      it 'reduces the height based on the number of files in the object (1 file)' do
        stub_purl_response_and_request(file_purl, request)
        expect(file_viewer.send(:default_height)).to eq 92
      end

      it 'reduces the height based on the number of files in the object (2 files)' do
        stub_purl_response_and_request(image_purl, request)
        expect(file_viewer.send(:default_height)).to eq 191
      end
    end

    context 'when the title bar is present' do
      before do
        expect(request).to receive(:hide_title?).at_least(:once).and_return(false)
      end

      it 'adds the necessary height' do
        stub_purl_response_and_request(file_purl, request)
        expect(file_viewer.send(:default_height)).to eq 132
      end
    end

    context 'when the title and search bar are present' do
      before do
        expect(request).to receive(:min_files_to_search).and_return(3)
        expect(request).to receive(:hide_title?).at_least(:once).and_return(false)
        expect(request).to receive(:hide_search?).at_least(:once).and_return(false)
      end

      it 'adds height if the title or search is hidden' do
        stub_purl_response_and_request(multi_resource_multi_type_purl, request)
        expect(file_viewer.send(:default_height)).to eq 398
      end
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
