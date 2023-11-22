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

  describe '#caption_files' do
    context 'when it has a caption file' do
      subject { resource.caption_files[0].title }

      let(:resource) { build(:resource, :video) }

      it { is_expected.to eq 'abc_123_cap.vtt' }
    end

    context 'when it does not have a caption file' do
      subject { resource.caption_files[0] }

      let(:resource) { build(:resource, :video, files: [build(:resource_file, :video)]) }

      before { stub_purl_xml_response_with_fixture(single_video_purl) }

      it { is_expected.to be_nil }
    end
  end
end
