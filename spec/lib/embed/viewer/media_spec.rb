# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Viewer::Media do
  subject(:media_viewer) { described_class.new(request) }

  let(:request) { Embed::Request.new({ url: 'http://purl.stanford.edu/bc123df4567', filename:, page: }.compact) }
  let(:filename) { nil }
  let(:page) { nil }
  let(:purl) do
    build(:purl, :video, contents: [
            build(:resource, :video),
            build(:resource, :file), # no primary file, so it cannot be displayed
            build(:resource, :image, files: [build(:media_file, :image)]),
            build(:resource, :media_pdf)
          ])
  end

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
  end

  describe '#importmap' do
    subject { media_viewer.importmap }

    it { is_expected.to eq 'media' }
  end

  describe '#displayable_resources' do
    it 'omits resources that have no primary file' do
      expect(media_viewer.displayable_resources.map(&:type)).to eq %w[video image file]
    end
  end

  describe '#selected_index' do
    it 'opens on the first resource when no filename was requested' do
      expect(media_viewer.selected_index).to eq 0
    end

    context 'when a filename was requested' do
      let(:filename) { 'program_notes.pdf' }

      it 'opens on that resource, counting only the displayable ones' do
        expect(media_viewer.selected_index).to eq 2
      end
    end

    context 'when the requested filename is not on the object' do
      let(:filename) { 'nope.pdf' }

      it 'falls back to the first resource' do
        expect(media_viewer.selected_index).to eq 0
      end
    end

    context 'when the requested filename belongs to a resource with no primary file' do
      let(:filename) { 'data.zip' }

      it 'falls back to the first resource' do
        expect(media_viewer.selected_index).to eq 0
      end
    end
  end

  describe '#selected_file_url' do
    it 'identifies the opening resource the way the IIIF manifest does' do
      expect(media_viewer.selected_file_url)
        .to eq 'https://stacks.stanford.edu/file/bc123df4567/abc_123.mp4'
    end

    context 'when a PDF was requested' do
      let(:filename) { 'program_notes.pdf' }

      it 'uses the file URL' do
        expect(media_viewer.selected_file_url)
          .to eq 'https://stacks.stanford.edu/file/bc123df4567/program_notes.pdf'
      end
    end

    context 'when an image was requested' do
      let(:filename) { 'image_001.jp2' }

      it 'uses the image server URL, because that is what the manifest paints' do
        expect(media_viewer.selected_file_url)
          .to eq 'https://stacks.stanford.edu/image/iiif/bc123df4567%2Fimage_001/full/full/0/default.jpg'
      end
    end
  end

  describe '#page' do
    it 'is nil when no page was requested' do
      expect(media_viewer.page).to be_nil
    end

    context 'when a page was requested' do
      let(:page) { '4' }

      it 'is the one-based page number' do
        expect(media_viewer.page).to eq 4
      end
    end

    context 'when the page is not a number' do
      let(:page) { 'invalid' }

      it 'is nil' do
        expect(media_viewer.page).to be_nil
      end
    end
  end
end
