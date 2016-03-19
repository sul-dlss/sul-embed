require 'rails_helper'

describe Embed::Request do
  let(:purl) { "#{Settings.purl_url}/abc123" }
  describe 'format' do
    it 'defaults to json when no format is provided' do
      expect(described_class.new(url: purl).format).to eq 'json'
    end
    it 'honors format parameters sent in through the URL' do
      expect(described_class.new(url: purl, format: 'xml').format).to eq 'xml'
    end
  end
  describe 'hide_title?' do
    it 'returns false by default' do
      expect(described_class.new(url: purl).hide_title?).to be_falsy
    end
    it 'returns true if the incoming request asked to hide the title' do
      expect(described_class.new(url: purl, hide_title: 'true').hide_title?).to be_truthy
    end
  end
  describe 'hide_metadata?' do
    it 'returns false by default' do
      expect(described_class.new(url: purl).hide_metadata?).to be_falsy
    end
    it 'returns true if incoming request asked to hide metadata panel' do
      expect(described_class.new(url: purl, hide_metadata: 'true').hide_metadata?).to be_truthy
    end
  end
  describe 'object_druid' do
    it 'parses the druid out of the incoming URL parameter' do
      expect(described_class.new(url: purl).object_druid).to eq 'abc123'
    end
  end
  describe 'rails_request' do
    let(:rails_request) { double('rails-request') }
    it 'includes the rails request (for generating asset URLs in viewer HTML)' do
      expect(described_class.new({ url: purl }, rails_request).rails_request).to eq rails_request
    end
  end
  describe 'purl_object' do
    let(:object) { double('purl') }
    it 'instantiates a PURL object w/ the object druid' do
      expect(Embed::PURL).to receive(:new).with('abc123').and_return(object)
      expect(described_class.new(url: purl).purl_object).to be object
    end
  end
  describe 'error handling' do
    it 'raises an error when no URL is provided' do
      expect(-> { described_class.new({}) }).to raise_error(Embed::Request::NoURLProvided)
    end
    it 'raises an error when a URL is provided that does not match the scheme' do
      expect(-> { described_class.new(url: 'http://library.stanford.edu') }).to raise_error(Embed::Request::InvalidURLScheme)
    end
    it 'raises an error when the scheme matches but there is no valid ID in the URL' do
      expect(-> { described_class.new(url: 'http://purl.stanford.edu/') }).to raise_error(Embed::Request::InvalidURLScheme)
    end
    it 'raises an error when an invalid format is requested' do
      expect(-> { described_class.new(url: 'http://purl.stanford.edu/abc', format: 'yml') }).to raise_error(Embed::Request::InvalidFormat)
    end
  end
end
