# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Purl do
  include PurlFixtures
  describe 'title' do
    let(:purl) { described_class.new(title: 'File Title') }

    it 'gets the objectLabel from the identityMetadata' do
      expect(purl.title).to eq 'File Title'
    end
  end

  describe 'type' do
    let(:purl) { described_class.new(type: 'file') }

    it 'gets the type attribute from the content metadata' do
      expect(purl.type).to eq 'file'
    end
  end

  describe 'embargoed?' do
    context 'when an item is embargoed' do
      subject(:purl) { described_class.new(embargoed: true) }

      it { is_expected.to be_embargoed }
    end

    context 'when an item is not embargoed' do
      subject(:purl) { described_class.new(embargoed: false) }

      it { is_expected.not_to be_embargoed }
    end
  end

  describe '#public?' do
    context 'when an item is public' do
      subject(:purl) { described_class.new(public: true) }

      it { is_expected.to be_public }
    end

    context 'when an item is not public' do
      subject(:purl) { described_class.new(public: false) }

      it { is_expected.not_to be_public }
    end
  end

  describe 'embargo_release_date' do
    let(:purl) { described_class.new(embargo_release_date: '2053-12-21') }

    it 'returns the date in the embargo field' do
      expect(purl.embargo_release_date).to match(/\d{4}-\d{2}-\d{2}/)
    end
  end

  describe 'valid?' do
    context 'with empty content metadata' do
      let(:purl) { described_class.new(contents: []) }

      it 'is false' do
        expect(purl).not_to be_valid
      end
    end

    context 'with content metadata' do
      let(:purl) { described_class.new(contents: [build(:resource)]) }

      it 'is true' do
        expect(purl).to be_valid
      end
    end
  end

  describe 'all_resource_files' do
    let(:purl) do
      described_class.new(contents: [
                            build(:resource, files: [build(:resource_file, :image), build(:resource_file, :image)]),
                            build(:resource, files: [build(:resource_file, :image), build(:resource_file, :image)])
                          ])
    end

    it 'returns a flattened array of resource files' do
      df = purl.all_resource_files
      expect(df).to all(be_a Embed::Purl::ResourceFile)
      expect(df.count).to eq 4
    end
  end

  describe '#size' do
    subject { purl.size }

    let(:purl) do
      described_class.new(contents: [
                            build(:resource, files: [build(:resource_file, :image)]),
                            build(:resource, files: [build(:resource_file, :image)])
                          ])
    end

    it { is_expected.to eq 12_345 * 2 }
  end

  describe '#downloadable_files' do
    subject(:df) { purl.downloadable_files }

    context 'when there are many resources with many files' do
      let(:purl) do
        described_class.new(contents: [
                              build(:resource, files: [build(:resource_file, :world_downloadable), build(:resource_file, :world_downloadable)]),
                              build(:resource, files: [build(:resource_file, :world_downloadable), build(:resource_file, :world_downloadable)])
                            ])
      end

      it 'returns a flattened array of downloadable resource files' do
        expect(df).to all(be_a Embed::Purl::ResourceFile)
        expect(df.count).to eq 4
      end
    end

    context 'when some of the files are no-download' do
      let(:purl) do
        described_class.new(contents: [
                              build(:resource, files: [build(:resource_file), build(:resource_file, :world_downloadable)]),
                              build(:resource, files: [build(:resource_file), build(:resource_file)])
                            ])
      end

      it 'returns only downloadable files (world)' do
        expect(df.count).to eq 1
      end
    end

    context 'when some of the files are stanford only' do
      let(:purl) do
        described_class.new(contents: [
                              build(:resource, files: [build(:resource_file), build(:resource_file, :stanford_only)]),
                              build(:resource, files: [build(:resource_file, :stanford_only)])
                            ])
      end

      it 'returns stanford only files' do
        expect(df.count).to eq 2
      end
    end
  end

  describe '#transcript_files' do
    subject(:df) { purl.transcript_files }

    context 'when some of the files are transcripts' do
      let(:purl) do
        described_class.new(contents: [build(:resource, files: [build(:resource_file, :transcript), build(:resource_file, :transcript)])])
      end

      it 'returns only transcript files' do
        expect(df.count).to eq 2
      end
    end
  end

  describe '#hierarchical_contents' do
    let(:root_dir) { Embed::Purl::ResourceDir.new('', [], []) }
    let(:purl) { described_class.new }

    before do
      allow(Embed::HierarchicalContents).to receive(:contents).and_return(root_dir)
    end

    it 'returns root ResourceDir' do
      expect(purl.hierarchical_contents).to be root_dir
      expect(Embed::HierarchicalContents).to have_received(:contents).with(purl.contents)
    end
  end

  describe '#manifest_json_url' do
    subject { purl.manifest_json_url }

    let(:purl) { described_class.new({ druid: '12345' }) }

    it { is_expected.to eq 'https://purl.stanford.edu/12345/iiif/manifest' }
  end

  describe '#manifest_json_response' do
    subject(:fetch) { purl.manifest_json_response }

    let(:purl) { described_class.find('12345') }

    context 'with a response' do
      before do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(response)
      end

      context 'when the status is success' do
        let(:response) { instance_double(Faraday::Response, body: '{}', success?: true) }

        it { is_expected.to eq '{}' }
      end

      context 'when the status is not success' do
        let(:response) { instance_double(Faraday::Response, success?: false, status: 404) }

        it 'raises an error' do
          expect { fetch }.to raise_error(Embed::Purl::ResourceNotAvailable)
        end
      end
    end

    context 'with a timeout' do
      before do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(Faraday::ConnectionFailed.new(''))
      end

      it 'raises an error' do
        expect { fetch }.to raise_error(Embed::Purl::ResourceNotAvailable)
      end
    end
  end
end
