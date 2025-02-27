# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Viewer::ModelViewer do
  subject(:viewer) { described_class.new(request) }

  let(:purl) do
    instance_double(
      Embed::Purl,
      contents:,
      location_restriction: false,
      embargoed?: false,
      stanford_only_unrestricted?: false,
      druid: 'abc123'
    )
  end
  let(:contents) do
    [
      instance_double(Embed::Purl::Resource, three_dimensional?: true,
                                             files: [instance_double(Embed::Purl::ResourceFile, title: 'obj1.glb', file_url: '//file/druid:abc123/obj1.glb', no_download?: false)])
    ]
  end
  let(:request) { instance_double(Embed::Request, purl_object: purl) }

  describe '#three_dimensional_files' do
    context 'with downloadable files' do
      it 'returns the full file URL for the PDFs in an object' do
        expect(viewer.three_dimensional_files.length).to eq 1
        expect(viewer.three_dimensional_files.first).to match(%r{/file/druid:abc123/obj1\.glb$})
      end
    end

    context 'with no download' do
      let(:contents) do
        [
          instance_double(Embed::Purl::Resource, three_dimensional?: true,
                                                 files: [instance_double(Embed::Purl::ResourceFile, title: 'obj1.glb', file_url: '//file/druid:abc123/obj1.glb', no_download?: true)])
        ]
      end

      it 'returns no files' do
        expect(viewer.three_dimensional_files.length).to eq 0
      end
    end
  end

  describe 'message' do
    context 'with location restricted' do
      let(:purl) do
        build(:purl, :location_restriction, :restricted_location, contents:)
      end

      it 'has a message of location restricted' do
        expect(viewer.authorization.message[:message]).to eq 'Access is restricted to the Special collections reading room. See Access conditions for more information.'
        expect(viewer.authorization.message[:type]).to eq 'location-restricted'
      end
    end

    context 'with location restiction on the file' do
      let(:contents) do
        [
          instance_double(Embed::Purl::Resource, three_dimensional?: true,
                                                 files: [instance_double(Embed::Purl::ResourceFile, download: 'location-based', title: 'obj1.glb', file_url: '//file/druid:abc123/obj1.glb', no_download?: true)])
        ]
      end

      it 'has no message' do
        expect(viewer.authorization.message).to be false
      end
    end
  end
end
