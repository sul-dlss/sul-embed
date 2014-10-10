require 'rails_helper'

describe Embed::Viewer::CommonViewer do
  include PURLFixtures
  let(:request) { double('request') }
  let(:file_viewer) { Embed::Viewer::File.new(request) }

  describe 'header_html' do
    it 'should return the objects title' do
      stub_purl_response_and_request(file_purl, request)
      html = Capybara.string(file_viewer.header_html)
      expect(html).to have_css 'div.sul-embed-header', text: 'File Title'
    end
  end
  describe 'footer_html' do
    it 'should return the objects footer' do
      stub_request(request)
      html = Capybara.string(file_viewer.footer_html)
      expect(html).to have_css 'div,sul-embed-footer a', text: 'http://purl.stanford.edu/12345'
    end
  end
end
