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

  describe 'height' do
    before { stub_purl_response_with_fixture(multi_file_purl) }

    context 'when the requested maxheight is larger than the default height' do
      let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123', maxheight: 600) }

      it 'is the default height (max is a maximum, we can be smaller)' do
        expect(file_viewer.height).to eq 257 # 2 files + header
      end
    end

    context 'when the requested maxheight is smaller than the default height' do
      let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123', maxheight: 200) }

      it 'is the requested maxheight' do
        expect(file_viewer.height).to eq 200
      end
    end

    context 'whne there is no requseted maxheight' do
      it 'is the default height' do
        expect(file_viewer.height).to eq 257 # 2 files + header
      end
    end
  end

  describe 'default_height' do
    context 'when title and search is hidden' do
      before do
        expect(request).to receive(:hide_title?).at_least(:once).and_return(true)
        expect(request).to receive(:hide_search?).at_least(:once).and_return(true)
      end

      it 'defaults to 323' do
        stub_purl_response_and_request(multi_resource_multi_type_purl, request)
        expect(file_viewer.send(:default_height)).to eq 323
      end

      it 'reduces the height based on the number of files in the object (1 file)' do
        stub_purl_response_and_request(file_purl, request)
        expect(file_viewer.send(:default_height)).to eq 122
      end

      it 'reduces the height based on the number of files in the object (2 files)' do
        stub_purl_response_and_request(image_purl, request)
        expect(file_viewer.send(:default_height)).to eq 189
      end
    end

    context 'when the item is emargoed' do
      before do
        expect(request).to receive(:hide_title?).at_least(:once).and_return(true)
        expect(request).to receive(:hide_search?).at_least(:once).and_return(true)
      end

      it 'adds 44 pixels to the height (to avoid unnecessary scroll)' do
        stub_purl_response_and_request(embargoed_stanford_file_purl, request)

        expect(file_viewer.send(:default_height)).to eq 166 # 122 + 44
      end
    end

    context 'when the title bar is present' do
      before do
        expect(request).to receive(:hide_title?).at_least(:once).and_return(false)
      end

      it 'adds the necessary height' do
        stub_purl_response_and_request(file_purl, request)
        expect(file_viewer.send(:default_height)).to eq 190
      end
    end
  end

  describe 'header_height' do
    context 'when the title bar and search bar is hidden' do
      before do
        expect(request).to receive(:hide_title?).at_least(:once).and_return(true)
        expect(request).to receive(:hide_search?).at_least(:once).and_return(true)
      end

      it { expect(file_viewer.send(:header_height)).to be_zero }
    end

    context 'when the title bar is hidden but a search is present' do
      before do
        stub_purl_response_and_request(multi_resource_multi_type_purl, request)
        expect(file_viewer).to receive(:min_files_to_search).and_return(3)
        expect(request).to receive(:hide_title?).at_least(:once).and_return(true)
      end

      it 'is 40 for the search bar' do
        expect(file_viewer.send(:header_height)).to eq 40
      end
    end

    context 'when the title bar is present' do
      it 'is 68 because it will show the title + number of items' do
        expect(file_viewer.send(:header_height)).to eq 68
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
