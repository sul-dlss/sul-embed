# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Purl::ResourceFile do
  include PurlFixtures
  describe 'attributes' do
    let(:resource_file) { build(:resource_file, :document) }

    it 'gets the title from from the id attribute' do
      expect(resource_file.title).to eq 'Title of the PDF.pdf'
    end

    it 'gets the hierarchical_title from from the id attribute' do
      expect(resource_file.hierarchical_title).to eq 'Title of the PDF.pdf'
    end

    it 'gets the mimetype from the mimetype attribute' do
      expect(resource_file.mimetype).to eq 'application/pdf'
    end

    it 'gets the size from the size attribute' do
      expect(resource_file.size).to eq 12_345
    end
  end

  describe '#file_url' do
    let(:filename) { 'cool_file' }
    let(:resource) { instance_double(Embed::Purl::Resource, druid: 'abc123') }
    let(:resource_file) { described_class.new(druid: 'abc123', filename:) }

    it 'creates a stacks file url' do
      expect(resource_file.file_url).to eq 'https://stacks.stanford.edu/file/druid:abc123/cool_file'
    end

    it 'adds a download param' do
      expect(resource_file.file_url(download: true)).to eq 'https://stacks.stanford.edu/file/druid:abc123/cool_file?download=true'
    end

    context 'when there are special characters in the file name' do
      let(:filename) { '[Dissertation] micro-TEC vfinal (for submission)-augmented.pdf' }

      it 'escapes them' do
        expect(resource_file.file_url).to eq 'https://stacks.stanford.edu/file/druid:abc123/%5BDissertation%5D%20micro-TEC%20vfinal%20%28for%20submission%29-augmented.pdf'
      end
    end

    context 'when there are literal slashes in the file name' do
      let(:filename) { 'path/to/[Dissertation] micro-TEC vfinal (for submission)-augmented.pdf' }

      it 'allows them' do
        expect(resource_file.file_url)
          .to eq 'https://stacks.stanford.edu/file/druid:abc123/path/to/%5BDissertation%5D%20micro-TEC%20vfinal%20%28for%20submission%29-augmented.pdf'
      end
    end
  end

  describe '#hierarchical_title' do
    let(:resource_file) { build(:resource_file, :hierarchical_file) }

    it 'get the hierarchical title from the id attribute' do
      expect(resource_file.hierarchical_title).to eq 'Title_of_2_PDF.pdf'
    end
  end

  describe '#label' do
    let(:resource_file) { described_class.new(label: 'The Resource Description') }

    it 'is the resource description' do
      expect(resource_file.label).to eq 'The Resource Description'
    end
  end

  describe 'image?' do
    context 'with an image' do
      let(:resource_file) { build(:resource_file, :image) }

      it 'returns true if the mimetype of the file is an image' do
        expect(resource_file).to be_image
      end
    end

    context 'with a document' do
      let(:resource_file) { build(:resource_file, :document) }

      it 'returns false if the mimetype of the file is not an image' do
        expect(resource_file).not_to be_image
      end
    end
  end

  describe 'rights' do
    subject { resource_file }

    describe 'stanford_only?' do
      context 'when stanford only' do
        let(:resource_file) { build(:resource_file, :document, :stanford_only) }

        it { is_expected.to be_stanford_only }
      end

      context 'when not stanford only' do
        let(:resource_file) { build(:resource_file, :document) }

        it { is_expected.not_to be_stanford_only }
      end
    end

    describe 'location_restricted?' do
      context 'when location restricted' do
        let(:resource_file) { build(:resource_file, :document, :location_restricted) }

        it { is_expected.to be_location_restricted }
      end

      context 'when not location restricted' do
        let(:resource_file) { build(:resource_file, :document) }

        it { is_expected.not_to be_location_restricted }
      end
    end

    describe 'world_downloadable?' do
      context 'when world downloadable' do
        let(:resource_file) { build(:resource_file, :document, :world_downloadable) }

        it { is_expected.to be_world_downloadable }
      end

      context 'when not world downloadable' do
        let(:resource_file) { build(:resource_file, :document) }

        it { is_expected.not_to be_world_downloadable }
      end
    end
  end

  describe '#vtt?' do
    subject { resource_file.vtt? }

    context 'when it is a vtt transcript' do
      let(:resource_file) { build(:resource_file, :vtt) }

      it { is_expected.to be true }
    end

    context 'when it is not a vtt transcript' do
      let(:resource_file) { build(:resource_file, :document) }

      it { is_expected.to be false }
    end
  end
end
