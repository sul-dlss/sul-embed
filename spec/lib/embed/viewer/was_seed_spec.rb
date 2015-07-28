require 'rails_helper'

describe Embed::Viewer::WasSeed do
  include PURLFixtures
  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:was_seed_viewer) { Embed::Viewer::WasSeed.new(request) }

  describe 'initialize' do
    it 'should be an Embed::Viewer::WasSeed' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(was_seed_viewer).to be_an Embed::Viewer::WasSeed
    end
  end
  describe 'self.supported_types' do
    it 'should return an array of supported types' do
      expect(Embed::Viewer::WasSeed.supported_types).to eq [:"webarchive-seed"]
    end
  end
  describe 'body_html' do
    it 'should return Was Seed viewer body' do
      expect(request).to receive(:hide_title?).at_least(:once).and_return(false)
      stub_purl_response_and_request(was_seed_purl, request)
      expect(was_seed_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')
      html = Capybara.string(was_seed_viewer.to_html)
      
      # visible false because we display:none the container until we've loaded the CSS.
      expect(html).to have_css '.sul-embed-was-seed', visible: false
    end
  end
end
