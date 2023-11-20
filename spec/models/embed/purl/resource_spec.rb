# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Purl::Resource do
  include PurlFixtures
  it 'gets the type attribute' do
    stub_purl_xml_response_with_fixture(file_purl_xml)
    expect(Embed::Purl.new('12345').contents.first.type).to eq 'file'
  end

  it 'gets the description from the label element' do
    stub_purl_xml_response_with_fixture(file_purl_xml)
    expect(Embed::Purl.new('12345').contents.first.description).to eq 'File1 Label'
  end

  describe '#thumbnail' do
    let(:resource) do
      described_class.new(
        druid: '12345',
        type: 'file',
        description: 'great',
        files: [
          Embed::Purl::ResourceFile.new(filename: 'Non thumb', mimetype: 'image/tiff'),
          Embed::Purl::ResourceFile.new(filename: 'The thumb', mimetype: 'image/jp2')
        ]
      )
    end

    context 'when the resource has a thumbnail' do
      it 'is the thumbnail' do
        expect(resource.thumbnail.title).to eq 'The thumb'
      end
    end

    context 'when the resource does not have a file specific thumbnail' do
      let(:resource) do
        described_class.new(
          druid: '12345',
          type: 'file',
          description: 'bland',
          files: [
            Embed::Purl::ResourceFile.new(filename: 'Non thumb', mimetype: 'image/tiff'),
            Embed::Purl::ResourceFile.new(filename: 'Another non Thumb', mimetype: 'audio/aiff')
          ]
        )
      end

      it 'is nil' do
        expect(resource.thumbnail).to be_nil
      end
    end
  end

  describe 'files' do
    it 'returns an array of Purl::Resource::ResourceFile objects' do
      stub_purl_xml_response_with_fixture(file_purl_xml)
      expect(Embed::Purl.new('12345').contents.first.files.all?(Embed::Purl::ResourceFile)).to be true
    end
  end

  describe '#vtt' do
    let(:resource) { Embed::Purl.new('12345').contents.first }

    context 'when it has a vtt transcript' do
      subject { resource.vtt.title }

      before { stub_purl_xml_response_with_fixture(video_purl_with_vtt) }

      it { is_expected.to eq 'abc_123_cap.webvtt' }
    end

    context 'when it does not have a vtt transcript' do
      subject { resource.vtt }

      before { stub_purl_xml_response_with_fixture(single_video_purl) }

      it { is_expected.to be_nil }
    end
  end
end
