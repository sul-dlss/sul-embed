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
      before { stub_purl_xml_response_with_fixture(empty_content_metadata_purl) }

      it 'is false' do
        expect(described_class.find('12345')).not_to be_valid
      end
    end

    context 'with content metadata' do
      before { stub_purl_xml_response_with_fixture(file_purl_xml) }

      it 'is true' do
        expect(described_class.find('12345')).to be_valid
      end
    end
  end

  describe '#collections' do
    it 'formats a list of collection druids' do
      stub_purl_xml_response_with_fixture(was_seed_purl)
      expect(described_class.find('12345').collections).to eq ['mk656nf8485']
    end

    it 'is empty when no collection is present in xml' do
      stub_purl_xml_response_with_fixture(file_purl_xml)
      expect(described_class.find('12345').collections).to eq []
    end
  end

  describe 'contents' do
    it 'returns an array of resources' do
      stub_purl_xml_response_with_fixture(file_purl_xml)
      expect(described_class.find('12345').contents.all?(Embed::Purl::Resource)).to be true
    end
  end

  describe 'all_resource_files' do
    it 'returns a flattened array of resource files' do
      stub_purl_xml_response_with_fixture(multi_resource_multi_type_purl)
      df = described_class.find('12345').all_resource_files
      expect(df).to be_an_instance_of Array
      expect(df.first).to be_an_instance_of Embed::Purl::ResourceFile
      expect(df.count).to eq 4
    end
  end

  describe '#size' do
    subject { purl.size }

    before do
      stub_purl_xml_response_with_fixture(multi_file_purl_xml)
    end

    let(:purl) { described_class.find('12345') }

    it { is_expected.to eq 12_345 * 2 }
  end

  describe '#downloadable_files' do
    it 'returns a flattened array of downloadable resource files' do
      stub_purl_xml_response_with_fixture(multi_resource_multi_type_purl)
      df = described_class.find('12345').downloadable_files
      expect(df).to be_an_instance_of Array
      expect(df.first).to be_an_instance_of Embed::Purl::ResourceFile
      expect(df.count).to eq 4
    end

    it 'returns only downloadable files (world)' do
      stub_purl_xml_response_with_fixture(world_restricted_download_purl)
      purl_obj = described_class.find('12345')
      expect(purl_obj.all_resource_files.count).to eq 3
      expect(purl_obj.downloadable_files.count).to eq 1
    end

    it 'returns only downloadable files (stanford)' do
      stub_purl_xml_response_with_fixture(stanford_restricted_download_purl)
      purl_obj = described_class.find('5678')
      expect(purl_obj.all_resource_files.count).to eq 3
      expect(purl_obj.downloadable_files.count).to eq 2
    end
  end

  describe 'public?' do
    it 'returns true if the object is publicly accessible' do
      stub_purl_xml_response_with_fixture(file_purl_xml)
      expect(described_class.find('12345')).to be_public
    end

    it 'returns false if the object is Stanford Only' do
      stub_purl_xml_response_with_fixture(stanford_restricted_file_purl_xml)
      expect(described_class.find('12345')).not_to be_public
    end
  end

  describe '#hierarchical_contents' do
    let(:root_dir) { Embed::Purl::ResourceDir.new('', [], []) }
    let(:purl) { described_class.find('12345') }

    before do
      stub_purl_xml_response_with_fixture(hierarchical_file_purl_xml)
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
