# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Response, type: 'view' do
  let(:viewer) { instance_double(Embed::Viewer::CommonViewer, embed_request:, purl_object:) }
  let(:embed_request) { Embed::Request.new({ url: 'http://purl.stanford.edu/abc123' }) }
  let(:purl_object) { instance_double(Embed::Purl, druid: 'abc123', version_id: nil) }
  let(:response) { described_class.new(embed_request) }

  describe 'static attributes' do
    it 'defines type' do
      expect(response.type).to eq 'rich'
    end

    it 'defines version' do
      expect(response.version).to eq '1.0'
    end

    it 'defines provider name' do
      expect(response.provider_name).to eq 'SUL Embed Service'
    end
  end

  describe 'title' do
    before do
      expect(embed_request).to receive(:purl_object).and_return(purl_object)
      expect(purl_object).to receive(:title).and_return('Purl Title')
    end

    it 'gets the title from the Purl object' do
      expect(response.title).to eq 'Purl Title'
    end
  end

  describe 'html' do
    before do
      expect(response).to receive(:viewer).at_least(:once).and_return(viewer)
      expect(embed_request).to receive(:fullheight?).and_return(nil)
      allow(viewer).to receive_messages(height: '100', width: '100', iframe_title: 'Kewl Viewer')
    end

    it 'is the iframe snippet pointing to the embed' do
      expect(response.html(controller)).to match(%r{<iframe.*src="#{controller.iframe_url}.*".*></iframe>}m)
    end
  end

  describe 'embed hash' do
    before do
      expect(embed_request).to receive(:purl_object).at_least(:once).and_return(purl_object)
      expect(embed_request).to receive(:fullheight?).and_return(nil)
      expect(purl_object).to receive(:title).and_return('Purl Title')
      expect(response).to receive(:viewer).at_least(:once).and_return(viewer)
      allow(viewer).to receive_messages(height: '100', width: '100', iframe_title: 'Kewl Viewer')
    end

    it 'provides a hash that conforms to the oEmbed SPEC' do
      embed_hash = response.embed_hash(controller)
      expect(embed_hash).to match(
        a_hash_including(
          type: 'rich',
          version: '1.0',
          provider_name: 'SUL Embed Service',
          title: 'Purl Title',
          height: '100',
          width: '100'
        )
      )
      expect(embed_hash[:html]).to match(%r{<iframe.*></iframe>}m)
    end
  end
end
