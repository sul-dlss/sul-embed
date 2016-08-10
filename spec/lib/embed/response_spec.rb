require 'rails_helper'

describe Embed::Response do
  let(:viewer) { double('viewer') }
  let(:request) { double('request', as_url_params: {}) }
  let(:purl_object) { double('purl_object', druid: 'abc123') }
  let(:response) { Embed::Response.new(request) }
  describe 'static attributes' do
    it 'should define type' do
      expect(response.type).to eq 'rich'
    end
    it 'should define version' do
      expect(response.version).to eq '1.0'
    end
    it 'should define provider name' do
      expect(response.provider_name).to eq 'SUL Embed Service'
    end
  end
  describe 'title' do
    before do
      expect(request).to receive(:purl_object).and_return(purl_object)
      expect(purl_object).to receive(:title).and_return('PURL Title')
    end
    it 'should get the title from the PURL object' do
      expect(response.title).to eq 'PURL Title'
    end
  end

  describe 'viewer_html' do
    before do
      expect(response).to receive(:viewer).at_least(:once).and_return(viewer)
      expect(viewer).to receive(:to_html).and_return('The Viewers Stubbed HTML')
    end
    it "proxies the viewer's full HTML output (to be used in the /iframe response)" do
      expect(response.viewer_html).to eq('The Viewers Stubbed HTML')
    end
  end
  describe 'html' do
    before do
      expect(response).to receive(:viewer).at_least(:once).and_return(viewer)
      expect(request).to receive(:purl_object).and_return(purl_object)
      allow(viewer).to receive(:height).and_return('100')
      allow(viewer).to receive(:width).and_return('100')
    end
    it 'is the iframe snippet pointing to the embed' do
      expect(response.html).to match(%r{<iframe src='//embed\.stanford\.edu.*'.*/>})
    end
  end
  describe 'embed hash' do
    before do
      expect(request).to receive(:purl_object).at_least(:once).and_return(purl_object)
      expect(purl_object).to receive(:title).and_return('PURL Title')
      expect(response).to receive(:viewer).at_least(:once).and_return(viewer)
      allow(viewer).to receive(:height).and_return('100')
      allow(viewer).to receive(:width).and_return('100')
    end
    it 'should provide a hash that conforms to the oEmbed SPEC' do
      embed_hash = response.embed_hash
      expect(embed_hash).to match(
        a_hash_including(
          type: 'rich',
          version: '1.0',
          provider_name: 'SUL Embed Service',
          title: 'PURL Title',
          height: '100',
          width: '100'
        )
      )
      expect(embed_hash[:html]).to match(%r{<iframe .*/>})
    end
  end
end
