# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Purl::Resource do
  include PurlFixtures
  it 'gets the sequence attribute' do
    stub_purl_response_with_fixture(file_purl)
    expect(Embed::Purl.new('12345').contents.first.sequence).to eq '1'
  end

  it 'gets the type attribute' do
    stub_purl_response_with_fixture(file_purl)
    expect(Embed::Purl.new('12345').contents.first.type).to eq 'file'
  end

  it 'gets the description from the label element' do
    stub_purl_response_with_fixture(file_purl)
    expect(Embed::Purl.new('12345').contents.first.description).to eq 'File1 Label'
  end

  it 'gets the description from the attr[name="label"] element' do
    stub_purl_response_with_fixture(multi_file_purl)
    expect(Embed::Purl.new('12345').contents.first.description).to eq 'File1 Label'
  end

  describe '#object_thumbnail?' do
    let(:purl_resource) { double('Resource') }

    it 'is true when type="thumb"' do
      allow(purl_resource).to receive(:attributes).and_return('type' => double(value: 'thumb'))
      expect(described_class.new(purl_resource, double('Rights'))).to be_object_thumbnail
    end

    it 'is true when thumb="yes"' do
      allow(purl_resource).to receive(:attributes).and_return('thumb' => double(value: 'yes'))
      expect(described_class.new(purl_resource, double('Rights'))).to be_object_thumbnail
    end

    it 'is false otherwise' do
      allow(purl_resource).to receive(:attributes).and_return('type' => double(value: 'image'))
      expect(described_class.new(purl_resource, double('Rights'))).not_to be_object_thumbnail
    end
  end

  describe 'files' do
    it 'returns an array of Purl::Resource::ResourceFile objects' do
      stub_purl_response_with_fixture(file_purl)
      expect(Embed::Purl.new('12345').contents.first.files.all?(Embed::Purl::ResourceFile)).to be true
    end
  end

  describe '#manifest_json_url' do
    it 'constructs a URL to a IIIF manifest' do
      expect(Embed::Purl.new('12345').manifest_json_url).to eq 'https://purl.stanford.edu/12345/iiif/manifest'
    end
  end

  describe '#manifest_json_response' do
    it 'fetches the IIIF manifest' do
      allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(instance_double(Faraday::Response, body: '{}', success?: true))
      expect(Embed::Purl.new('12345').manifest_json_response).to eq '{}'
    end

    it 'raises an application error on failure' do
      allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(instance_double(Faraday::Response, success?: false))
      expect { Embed::Purl.new('12345').manifest_json_response }.to raise_error(Embed::Purl::ResourceNotAvailable)
    end

    it 'raises an application error on timeout' do
      allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(Faraday::ConnectionFailed.new(''))
      expect { Embed::Purl.new('12345').manifest_json_response }.to raise_error(Embed::Purl::ResourceNotAvailable)
    end
  end
end
