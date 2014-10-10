require 'rails_helper'

describe Embed::Viewer::CommonViewer do
  include PURLFixtures
  let(:rails_request) { double('rails_request') }
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
      expect(request).to receive(:rails_request).and_return(rails_request)
      expect(rails_request).to receive(:host_with_port).and_return('example.com')
      html = Capybara.string(file_viewer.footer_html)
      expect(html).to have_css 'div.sul-embed-footer a', text: 'http://purl.stanford.edu/12345'
    end
  end
  describe 'to_html' do
    it 'should return html that has header, body, and footer wrapped in a container' do
      stub_request(request)
      expect(file_viewer).to receive(:body_html).and_return('<div class="sul-embed-body"></div>')
      expect(file_viewer).to receive(:header_html).and_return('<div class="sul-embed-header"></div>')
      expect(file_viewer).to receive(:footer_html).and_return('<div class="sul-embed-footer"></div>')
      html = Capybara.string(file_viewer.to_html)
      expect(html).to have_css 'div.sul-embed-container'
      expect(html).to have_css 'div.sul-embed-body'
      expect(html).to have_css 'div.sul-embed-header'
      expect(html).to have_css 'div.sul-embed-footer'
    end
  end
end
