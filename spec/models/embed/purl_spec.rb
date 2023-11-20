# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Purl do
  include PurlFixtures
  describe 'title' do
    before { stub_purl_xml_response_with_fixture(file_purl_xml) }

    it 'gets the objectLabel from the identityMetadata' do
      expect(described_class.find('12345').title).to eq 'File Title'
    end
  end

  describe 'type' do
    before { stub_purl_xml_response_with_fixture(file_purl_xml) }

    it 'gets the type attribute from the content metadata' do
      expect(described_class.find('12345').type).to eq 'file'
    end
  end

  describe 'embargoed?' do
    it 'returns true when an item is embargoed' do
      stub_purl_xml_response_with_fixture(embargoed_file_purl_xml)
      expect(described_class.find('12345')).to be_embargoed
    end

    it 'returns false when an item is not embargoed' do
      stub_purl_xml_response_with_fixture(file_purl_xml)
      expect(described_class.find('12345')).not_to be_embargoed
    end
  end

  describe '#world_unrestricted?' do
    it 'without a world restriction' do
      stub_purl_xml_response_with_fixture(image_purl_xml)
      expect(described_class.find('12345')).to be_world_unrestricted
    end

    it 'when it has a world restriction' do
      stub_purl_xml_response_with_fixture(stanford_restricted_image_purl_xml)
      expect(described_class.find('12345')).not_to be_world_unrestricted
    end
  end

  describe 'embargo_release_date' do
    before { stub_purl_xml_response_with_fixture(embargoed_file_purl_xml) }

    it 'returns the date in the embargo field' do
      expect(described_class.find('12345').embargo_release_date).to match(/\d{4}-\d{2}-\d{2}/)
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

  describe '#bounding_box' do
    before { stub_purl_xml_response_with_fixture(geo_purl_public) }

    it 'creates an Envelope and calls #to_bounding_box on it' do
      expect_any_instance_of(Embed::Envelope).to receive(:to_bounding_box)
      described_class.find('12345').bounding_box
    end
  end

  describe '#envelope' do
    it 'selects the envelope element' do
      stub_purl_xml_response_with_fixture(geo_purl_public)
      expect(described_class.find('12345').envelope).to be_an Nokogiri::XML::Element
    end

    it 'without an envelope present' do
      stub_purl_xml_response_with_fixture(image_purl_xml)
      expect(described_class.find('12345').envelope).to be_nil
    end
  end

  describe 'license' do
    it 'returns cc license if present' do
      stub_purl_xml_response_with_fixture(file_purl_xml)
      purl = described_class.find('12345')
      expect(purl.license).to eq 'Public Domain Mark 1.0'
    end

    it 'returns odc license if present' do
      stub_purl_xml_response_with_fixture(hybrid_object_purl)
      purl = described_class.find('12345')
      expect(purl.license).to eq 'ODC-By Attribution License'
    end

    it 'returns MODS license if present' do
      stub_purl_xml_response_with_fixture(mods_license_purl)
      purl = described_class.find('12345')
      expect(purl.license).to eq 'This work is licensed under an Apache License 2.0 license.'
    end

    it 'returns nil if no license is present' do
      stub_purl_xml_response_with_fixture(embargoed_file_purl_xml)
      expect(described_class.find('12345').license).to be_nil
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

    let(:purl) { described_class.find('12345') }

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
