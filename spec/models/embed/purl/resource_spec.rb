# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Purl::Resource do
  include PurlFixtures
  let(:resource) do
    build(:resource, :file)
  end

  it 'has a type' do
    expect(resource.type).to eq 'file'
  end

  it 'has a description' do
    expect(resource.description).to eq 'File1 Label'
  end

  describe '#thumbnail' do
    let(:resource) do
      build(:resource, :file,
            files: [
              build(:resource_file, filename: 'Non thumb', mimetype: 'image/tiff'),
              build(:resource_file, filename: 'The thumb', mimetype: 'image/jp2')
            ])
    end

    context 'when the resource has a thumbnail' do
      it 'is the thumbnail' do
        expect(resource.thumbnail.title).to eq 'The thumb'
      end
    end

    context 'when the resource does not have a file specific thumbnail' do
      let(:resource) do
        build(:resource, :file,
              files: [
                build(:resource_file, filename: 'Non thumb', mimetype: 'image/tiff'),
                build(:resource_file, filename: 'Another non Thumb', mimetype: 'audio/aiff')
              ])
      end

      it 'is nil' do
        expect(resource.thumbnail).to be_nil
      end
    end
  end

  describe '#files' do
    let(:resource) do
      build(:resource, :file,
            files: [
              build(:resource_file, filename: 'Non thumb', mimetype: 'image/tiff'),
              build(:resource_file, filename: 'Another non Thumb', mimetype: 'audio/aiff')
            ])
    end

    it 'returns an array of files' do
      expect(resource.files.all?(Embed::Purl::ResourceFile)).to be true
    end
  end

  describe '#multilingual_captions?' do
    subject { described_class.new('12345', resource_element, instance_double(Dor::RightsAuth)) }

    context 'when there are no caption files' do
      let(:resource_element) do
        Nokogiri::XML(
          <<~XML
            <resource sequence="1" type="file">
              <file id="Non caption" mimetype="image/tiff" size="2799535" />
              <file id="Another non caption" mimetype="audio/aiff" size="2799535" />
            </resource>
          XML
        ).xpath('//resource').first
      end

      it { is_expected.not_to be_multilingual_captions }
    end

    context 'when there is one caption file' do
      let(:resource_element) do
        Nokogiri::XML(
          <<~XML
            <resource sequence="1" type="file">
              <file id="Non caption" mimetype="image/tiff" size="2799535" />
              <file id="caption" mimetype="text/vtt" size="2735" role="caption" />
            </resource>
          XML
        ).xpath('//resource').first
      end

      it { is_expected.not_to be_multilingual_captions }
    end

    context 'when there are multiple caption files without languages' do
      let(:resource_element) do
        Nokogiri::XML(
          <<~XML
            <resource sequence="1" type="file">
              <file id="caption" mimetype="text/vtt" size="2795" role="caption" />
              <file id="another caption" mimetype="text/vtt" size="2735" role="caption" />
            </resource>
          XML
        ).xpath('//resource').first
      end

      it { is_expected.not_to be_multilingual_captions }
    end

    context 'when there are multiple caption files with the same language' do
      let(:resource_element) do
        Nokogiri::XML(
          <<~XML
            <resource sequence="1" type="file">
              <file id="caption" mimetype="text/vtt" size="2795" role="caption" language="en" />
              <file id="another caption" mimetype="text/vtt" size="2735" role="caption" language="en" />
            </resource>
          XML
        ).xpath('//resource').first
      end

      it { is_expected.not_to be_multilingual_captions }
    end

    context 'when there are multiple caption files with one language' do
      let(:resource_element) do
        Nokogiri::XML(
          <<~XML
            <resource sequence="1" type="file">
              <file id="caption" mimetype="text/vtt" size="2795" role="caption" language="en" />
              <file id="another caption" mimetype="text/vtt" size="2735" role="caption" />
            </resource>
          XML
        ).xpath('//resource').first
      end

      it { is_expected.not_to be_multilingual_captions }
    end

    context 'when there are multiple caption files with different languages' do
      let(:resource_element) do
        Nokogiri::XML(
          <<~XML
            <resource sequence="1" type="file">
              <file id="caption" mimetype="text/vtt" size="2795" role="caption" language="en" />
              <file id="another caption" mimetype="text/vtt" size="2735" role="caption" language="ru" />
            </resource>
          XML
        ).xpath('//resource').first
      end

      it { is_expected.to be_multilingual_captions }
    end
  end

  describe '#vtt' do
    context 'when it has a vtt transcript' do
      subject { resource.vtt.title }

      let(:resource) { build(:resource, :video) }

      it { is_expected.to eq 'abc_123_cap.webvtt' }
    end

    context 'when it does not have a vtt transcript' do
      subject { resource.vtt }

      let(:resource) { build(:resource, :video, files: [build(:resource_file, :video)]) }

      before { stub_purl_xml_response_with_fixture(single_video_purl) }

      it { is_expected.to be_nil }
    end
  end
end
