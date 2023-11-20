# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Purl::ResourceFile do
  include PurlFixtures
  describe 'attributes' do
    before { stub_purl_xml_response_with_fixture(file_purl_xml) }

    let(:resource_file) { Embed::Purl.new('12345').contents.first.files.first }

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
    before { stub_purl_xml_response_with_fixture(hierarchical_file_purl_xml) }

    let(:resource_file) { Embed::Purl.new('12345').hierarchical_contents.dirs.first.dirs.first.files.first }

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

  describe '#label_or_filename' do
    subject { resource_file.label_or_filename }

    context 'with a label' do
      let(:resource_file) { described_class.new(label: 'The Resource Description') }

      it { is_expected.to eq 'The Resource Description' }
    end

    context 'without a blank label' do
      let(:resource_file) { described_class.new(label: '', filename: 'llama.mp3') }

      it { is_expected.to eq 'llama.mp3' }
    end
  end

  describe 'image?' do
    it 'returns true if the mimetype of the file is an image' do
      stub_purl_xml_response_with_fixture(image_purl_xml)
      expect(Embed::Purl.new('12345').contents.first.files.first).to be_image
    end

    it 'returns false if the mimetype of the file is not an image' do
      stub_purl_xml_response_with_fixture(file_purl_xml)
      expect(Embed::Purl.new('12345').contents.first.files.first).not_to be_image
    end
  end

  describe 'rights' do
    describe 'stanford_only?' do
      it 'identifies stanford_only objects' do
        stub_purl_xml_response_with_fixture(stanford_restricted_file_purl_xml)
        expect(Embed::Purl.new('12345').contents.first.files.all?(&:stanford_only?)).to be true
      end

      it 'identifies stanford_only no-download objects' do
        stub_purl_xml_response_with_fixture(stanford_no_download_restricted_file_purl_xml)
        expect(Embed::Purl.new('12345').contents.first.files.all?(&:stanford_only?)).to be true
      end

      it 'identifies world accessible objects as not stanford only' do
        stub_purl_xml_response_with_fixture(file_purl_xml)
        expect(Embed::Purl.new('12345').contents.first.files.all?(&:stanford_only?)).to be false
      end

      it 'identifies file-level stanford_only rights' do
        stub_purl_xml_response_with_fixture(stanford_restricted_multi_file_purl_xml)
        contents = Embed::Purl.new('12345').contents
        first_file = contents.first.files.first
        last_file = contents.last.files.first
        expect(first_file).to be_stanford_only
        expect(last_file).not_to be_stanford_only
      end
    end

    describe 'location_restricted?' do
      it 'identifies location restricted objects' do
        stub_purl_xml_response_with_fixture(single_video_purl)
        expect(Embed::Purl.new('12345').contents.first.files.all?(&:location_restricted?)).to be true
      end

      it 'identifies world accessible objects as not stanford only' do
        stub_purl_xml_response_with_fixture(file_purl_xml)
        expect(Embed::Purl.new('12345').contents.first.files.all?(&:location_restricted?)).to be false
      end

      it 'identifies file-level location_restricted rights' do
        stub_purl_xml_response_with_fixture(video_purl)
        contents = Embed::Purl.new('12345').contents
        first_file = contents.first.files.first
        last_file = contents.last.files.first
        expect(first_file).to be_location_restricted
        expect(last_file).not_to be_location_restricted
      end
    end

    describe 'world_downloadable?' do
      it 'is false for stanford-only objects' do
        stub_purl_xml_response_with_fixture(stanford_restricted_file_purl_xml)
        expect(Embed::Purl.new('12345').contents.first.files.all?(&:world_downloadable?)).to be false
      end

      it 'is false for no-download objects' do
        stub_purl_xml_response_with_fixture(stanford_no_download_restricted_file_purl_xml)
        expect(Embed::Purl.new('12345').contents.first.files.all?(&:world_downloadable?)).to be false
      end

      it 'is true for identify world accessible objects' do
        stub_purl_xml_response_with_fixture(file_purl_xml)
        expect(Embed::Purl.new('12345').contents.first.files.all?(&:world_downloadable?)).to be true
      end
    end
  end

  describe '#vtt?' do
    subject { file.vtt? }

    context 'when it is a vtt transcript' do
      let(:file) { Embed::Purl.new('12345').contents.first.files.second }

      before { stub_purl_xml_response_with_fixture(video_purl_with_vtt) }

      it { is_expected.to be true }
    end

    context 'when it is not a vtt transcript' do
      let(:file) { Embed::Purl.new('12345').contents.first.files.first }

      before { stub_purl_xml_response_with_fixture(single_video_purl) }

      it { is_expected.to be false }
    end
  end
end
