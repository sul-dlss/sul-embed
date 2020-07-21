# frozen_string_literal: true

require 'rails_helper'

describe Embed::ViewerFactory do
  include PurlFixtures

  let(:request) { double('EmbedRequest', purl_object: purl) }
  let(:purl) { Embed::Purl.new('ignored') }
  let(:instance) { described_class.new(request) }

  describe 'initialization' do
    subject { instance }
    context 'invalid Purl object' do
      before { stub_purl_response_with_fixture(empty_content_metadata_purl) }

      it 'raises an error' do
        expect { subject }.to raise_error(Embed::Purl::ResourceNotEmbeddable)
      end
    end

    context 'valid Purl object' do
      before { stub_purl_response_with_fixture(file_purl) }

      it 'initializes successfully' do
        expect { subject }.not_to raise_error
      end
    end
  end

  describe '#viewer' do
    before { stub_purl_response_with_fixture(image_purl) }
    subject { instance.viewer }
    context 'when the request has a type' do
      it { is_expected.to be_kind_of Embed::Viewer::M3Viewer }
    end

    context "when the request doesn't have a type" do
      before { allow(purl).to receive(:type).and_return('mustache') }
      it { is_expected.to be_kind_of Embed::Viewer::File }
    end
  end
end
