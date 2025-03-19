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

    let(:purl) { Embed::Purl.new(type: 'image', contents: [build(:resource)]) }

    context 'when the request has a type' do
      it { is_expected.to be_a Embed::Viewer::M3Viewer }
    end
  end
end
