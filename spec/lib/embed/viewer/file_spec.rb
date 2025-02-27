# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Viewer::File do
  let(:request) { Embed::Request.new({ url: 'http://purl.stanford.edu/abc123' }) }
  let(:file_viewer) { described_class.new(request) }
  let(:purl) { build(:purl) }

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
  end

  describe 'initialize' do
    it 'creates Embed::Viewer::File' do
      expect(file_viewer).to be_an described_class
    end
  end

  describe 'height' do
    let(:purl) do
      build(:purl, contents: [
              build(:resource, :file, files: [build(:resource_file)]),
              build(:resource, :file, files: [build(:resource_file)])
            ])
    end

    context 'when the requested maxheight is larger than the default height' do
      let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123', maxheight: '600') }

      it 'is the default height (max is a maximum, we can be smaller)' do
        expect(file_viewer.height).to eq '257px' # 2 files + header
      end
    end

    context 'when the requested maxheight is smaller than the default height' do
      let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123', maxheight: '200') }

      it 'is the requested maxheight' do
        expect(file_viewer.height).to eq '200px'
      end
    end

    context 'when there is no requested maxheight' do
      it 'is the default height' do
        expect(file_viewer.height).to eq '257px' # 2 files + header
      end
    end
  end

  describe 'message' do
    context 'with location restricted' do
      let(:purl) do
        build(:purl, :location_restriction, :restricted_location, contents: [build(:resource, :file, files: [build(:resource_file)])])
      end

      it 'has a message of location restricted' do
        expect(file_viewer.authorization.message[:message]).to eq 'Access is restricted to the Special collections reading room. See Access conditions for more information.'
        expect(file_viewer.authorization.message[:type]).to eq 'location-restricted'
      end
    end

    context 'with location restricted and stanford only' do
      let(:purl) do
        build(:purl, :file, :location_restriction, :stanford_only_unrestricted, contents: [build(:resource, :file, files: [build(:resource_file)])])
      end

      it 'has a message for stanford users' do
        expect(file_viewer.authorization.message[:message]).to eq 'Access is restricted to Stanford-affiliated patrons.'
        expect(file_viewer.authorization.message[:type]).to eq 'stanford'
      end
    end

    context 'with location restricted on a file' do
      let(:purl) do
        build(:purl, contents: [build(:resource, :file, files: [build(:resource_file, :location_restricted)])])
      end

      it 'has no message' do
        expect(file_viewer.authorization.message).to be false
      end
    end
  end

  describe 'default_height' do
    context 'when title and search is hidden' do
      before do
        expect(request).to receive(:hide_title?).at_least(:once).and_return(true)
        expect(request).to receive(:hide_search?).at_least(:once).and_return(true)
      end

      context 'with four files' do
        let(:purl) do
          build(:purl, contents: [
                  build(:resource, :file, files: [build(:resource_file)]),
                  build(:resource, :file, files: [build(:resource_file)]),
                  build(:resource, :file, files: [build(:resource_file)]),
                  build(:resource, :file, files: [build(:resource_file)])
                ])
        end

        it 'defaults to 323' do
          expect(file_viewer.send(:default_height)).to eq '323px'
        end
      end

      context 'with one file' do
        let(:purl) do
          build(:purl, contents: [build(:resource, :file, files: [build(:resource_file)])])
        end

        it 'reduces the height based on the number of files in the object, but no lower than our min height' do
          expect(file_viewer.send(:default_height)).to eq '189px'
        end
      end

      context 'with two files' do
        let(:purl) do
          build(:purl, contents: [
                  build(:resource, :file, files: [build(:resource_file)]),
                  build(:resource, :file, files: [build(:resource_file)])
                ])
        end

        it 'reduces the height based on the number of files in the object' do
          expect(file_viewer.send(:default_height)).to eq '189px'
        end
      end
    end

    context 'when the item is embargoed' do
      before do
        expect(request).to receive(:hide_title?).at_least(:once).and_return(true)
        expect(request).to receive(:hide_search?).at_least(:once).and_return(true)
      end

      it 'adds 44 pixels to the height (to avoid unnecessary scroll)' do
        expect(file_viewer.send(:default_height)).to eq '189px' # minimum height
      end
    end

    context 'when the title bar is present' do
      before do
        expect(request).to receive(:hide_title?).at_least(:once).and_return(false)
      end

      let(:purl) { build(:purl, contents: [build(:resource, files: [build(:resource_file)])]) }

      it 'adds the necessary height' do
        expect(file_viewer.send(:default_height)).to eq '190px'
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
      let(:purl) do
        build(:purl, contents: [
                build(:resource, :file, files: [build(:resource_file)]),
                build(:resource, :file, files: [build(:resource_file)]),
                build(:resource, :file, files: [build(:resource_file)]),
                build(:resource, :file, files: [build(:resource_file)])
              ])
      end

      before do
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
      expect(file_viewer.file_type_icon('application/null')).to eq Icons::InsertDriveFileComponent
    end

    it 'translated file icon for recognized mime type' do
      expect(file_viewer.file_type_icon('application/zip')).to eq Icons::FolderZipComponent
    end
  end

  describe 'display_download_all?' do
    subject { file_viewer.display_download_all? }

    context 'when there are not many files and the size is low' do
      let(:purl) do
        build(:purl, contents: [
                build(:resource, :file, files: [build(:resource_file, :world_downloadable)]),
                build(:resource, :file, files: [build(:resource_file, :world_downloadable)]),
                build(:resource, :file, files: [build(:resource_file, :world_downloadable)]),
                build(:resource, :file, files: [build(:resource_file, :world_downloadable)])
              ])
      end

      it { is_expected.to be true }
    end

    context 'when the files are too big' do
      let(:purl) do
        build(:purl, contents: [
                build(:resource, :file, files: [build(:resource_file, :world_downloadable, size: 10_737_418_241)])
              ])
      end

      it { is_expected.to be false }
    end

    context 'when there are too many files' do
      let(:purl) do
        build(:purl, contents: [
                build(:resource, :file, files: 1.upto(3001).map { build(:resource_file, :world_downloadable) })
              ])
      end

      it { is_expected.to be false }
    end
  end
end
