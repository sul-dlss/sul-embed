require 'rails_helper'

describe Embed::Viewer do
  include PURLFixtures

  let(:request) { double('EmbedRequest', purl_object: Embed::PURL.new('ignored')) }
  subject { described_class.new(request) }

  describe 'initialization' do
    context 'invalid PURL object' do
      before { stub_purl_response_with_fixture(empty_content_metadata_purl) }

      it 'raises an error' do
        expect { subject }.to raise_error(Embed::PURL::ResourceNotEmbeddable)
      end
    end

    context 'valid PURL object' do
      before { stub_purl_response_with_fixture(file_purl) }

      it 'initializes successfully' do
        expect { subject }.not_to raise_error
      end
    end
  end
end
