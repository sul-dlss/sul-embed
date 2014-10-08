require "rails_helper"

describe Embed::Response do
  let(:viewer)      { double('viewer') }
  let(:request)     { double('request') }
  let(:purl_object) { double('purl_object') }
  let(:response)    { Embed::Response.new(request) }
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
      expect(purl_object).to receive(:title).and_return("PURL Title")
    end
    it 'should get the title from the PURL object' do
      expect(response.title).to eq 'PURL Title'
    end
  end
  describe 'html' do
    before do
      expect(response).to receive(:viewer).and_return(viewer)
      expect(viewer).to receive(:to_html).and_return("the html")
    end
    it 'should get the HTML from the associated viewer' do
      expect(response.html).to eq 'the html'
    end
  end
  describe 'embed hash' do
    before do
      expect(request).to receive(:purl_object).and_return(purl_object)
      expect(purl_object).to receive(:title).and_return("PURL Title")
      expect(response).to receive(:viewer).at_least(:once).and_return(viewer)
      expect(viewer).to receive(:to_html).and_return("the html")
      expect(viewer).to receive(:height).and_return('100')
      expect(viewer).to receive(:width).and_return('100')
    end
    it 'should provide a hash that conforms to the oEmbed SPEC' do
      expect(response.embed_hash).to eq ({
        type: "rich",
        version: "1.0",
        provider_name: "SUL Embed Service",
        title: "PURL Title",
        height: "100",
        width: "100",
        html: "the html"
      })
    end
  end
end
