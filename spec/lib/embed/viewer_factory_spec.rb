# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::ViewerFactory do
  include PurlFixtures

  let(:request) { instance_double(Embed::Request, purl_object: purl) }
  let(:purl) { Embed::Purl.new('ignored') }
  let(:instance) { described_class.new(request) }

  describe 'initialization' do
    subject { instance }

    context 'invalid Purl object' do
      before do
        stub_request(:get, 'https://purl.stanford.edu/ignored.xml')
          .to_return(status: 200, body: empty_content_metadata_purl)
      end

      it 'raises an error' do
        expect { subject }.to raise_error(Embed::Purl::ResourceNotEmbeddable)
      end
    end

    context 'valid Purl object' do
      before do
        stub_request(:get, 'https://purl.stanford.edu/ignored.xml')
          .to_return(status: 200, body: file_purl)
      end

      it 'initializes successfully' do
        expect { subject }.not_to raise_error
      end
    end
  end

  describe '#viewer' do
    subject { instance.viewer }

    before do
      stub_request(:get, 'https://purl.stanford.edu/ignored.xml')
        .to_return(status: 200, body: image_purl)
    end

    context 'when the request has a type' do
      it { is_expected.to be_a Embed::Viewer::M3Viewer }
    end

    context "when the request doesn't have a type" do
      before { allow(purl).to receive(:type).and_return('mustache') }

      it { is_expected.to be_a Embed::Viewer::File }
    end
  end
end
