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
    context 'when the requested maxheight is provided' do
      let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123', maxheight: '600') }

      it 'is the provided height' do
        expect(file_viewer.height).to eq '600px'
      end
    end

    context 'when there is no requested maxheight' do
      it 'is the default height' do
        expect(file_viewer.height).to eq '500px'
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
