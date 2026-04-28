# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::ViewerFactory do
  let(:request) { instance_double(Embed::Request, purl_object: purl) }
  let(:instance) { described_class.new(request) }

  describe 'initialization' do
    subject { instance }

    context 'invalid Purl object' do
      let(:purl) { Embed::Purl.new(type: 'image', contents: [], constituents: []) }

      it 'raises an error' do
        expect { subject }.to raise_error(Embed::Purl::ResourceNotEmbeddable)
      end
    end

    context 'valid Purl object' do
      let(:purl) { Embed::Purl.new(type: 'file', contents: [build(:resource)]) }

      it 'initializes successfully' do
        expect { subject }.not_to raise_error
      end
    end
  end

  describe '#viewer' do
    subject { instance.viewer }

    context 'when the request has an image type' do
      let(:purl) { Embed::Purl.new(type: 'image', contents: [build(:resource)]) }

      it { is_expected.to be_a Embed::Viewer::MiradorViewer }
    end

    context 'when the request has a map type' do
      let(:purl) { Embed::Purl.new(type: 'map', contents: [build(:resource)]) }

      it { is_expected.to be_a Embed::Viewer::MiradorViewer }
    end

    context 'when the request has a map type and an annotation' do
      let(:purl) do
        Embed::Purl.new(type: 'map',
                        contents: [
                          build(:resource, files: [build(:resource_file, :world_downloadable, :annotations)])
                        ])
      end

      it { is_expected.to be_a Embed::Viewer::Geo }
    end
  end
end
