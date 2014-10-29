require 'rails_helper'

describe Embed::Viewer::CommonViewer do
  include PURLFixtures
  let(:rails_request) { double('rails_request') }
  let(:request) { Embed::Request.new({url: 'http://purl.stanford.edu/abc123'}) }
  let(:file_viewer) { Embed::Viewer::File.new(request) }

  describe 'header_html' do
    it 'should return the objects title' do
      expect(request).to receive(:params).at_least(:once).and_return({})
      expect(request).to receive(:hide_title?).at_least(:once).and_return(false)
      stub_purl_response_and_request(file_purl, request)
      html = Capybara.string(file_viewer.header_html)
      expect(html).to have_css '.sul-embed-header-title', text: 'File Title'
    end
    it 'should not return the object title if the consumer requested to hide it' do
      expect(request).to receive(:params).at_least(:once).and_return({})
      expect(request).to receive(:hide_title?).at_least(:once).and_return(true)
      stub_request(request)
      html = Capybara.string(file_viewer.header_html)
      expect(html).to_not have_css '.sul-embed-header-title'
    end
  end
  describe 'metadata_html' do
    it 'should return the metadata panel html' do
      stub_purl_response_and_request(file_purl, request)
      html = Capybara.string(file_viewer.metadata_html)
      expect(html).to have_css 'div.sul-embed-metadata-panel-container'
      expect(html).to have_css 'div.sul-embed-metadata-panel', visible: false
    end
    it 'should return use and reproduction' do
      stub_purl_response_and_request(file_purl, request)
      html = Capybara.string(file_viewer.metadata_html)
      expect(html).to have_content 'Use and reproduction'
    end
    it 'should not return use and reproduction' do
      stub_purl_response_and_request(image_purl, request)
      html = Capybara.string(file_viewer.metadata_html)
      expect(html).to_not have_content 'Use and reproduction'
    end
    it 'should return copyright' do
      stub_purl_response_and_request(image_purl, request)
      html = Capybara.string(file_viewer.metadata_html)
      expect(html).to have_content 'Copyright'
    end
    it 'should not return copyright' do
      stub_purl_response_and_request(file_purl, request)
      html = Capybara.string(file_viewer.metadata_html)
      expect(html).to_not have_content 'Copyright'
    end
    it 'should return license' do
      stub_purl_response_and_request(file_purl, request)
      html = Capybara.string(file_viewer.metadata_html)
      expect(html).to have_content 'License'
    end
    it 'should not return license' do
      stub_purl_response_and_request(image_purl, request)
      html = Capybara.string(file_viewer.metadata_html)
      expect(html).to_not have_content 'License'
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
      expect(file_viewer).to receive(:metadata_html).and_return('<div class="sul-embed-metadata-container"></div>')
      expect(file_viewer).to receive(:footer_html).and_return('<div class="sul-embed-footer"></div>')
      html = Capybara.string(file_viewer.to_html)
      # visible false because we display:none the container until we've loaded the CSS.
      expect(html).to have_css 'div.sul-embed-container', visible: false
      expect(html).to have_css 'div.sul-embed-body', visible: false
      expect(html).to have_css 'div.sul-embed-header', visible: false
      expect(html).to have_css 'div.sul-embed-metadata-container', visible: false
      expect(html).to have_css 'div.sul-embed-footer', visible: false
    end
    it 'should include the height/width style in the container if maxheight/width is passed' do
      expect(request).to receive(:maxheight).at_least(:once).and_return(200)
      expect(request).to receive(:maxwidth).at_least(:once).and_return(200)
      stub_request(request)
      expect(file_viewer).to receive(:body_html).and_return('<div class="sul-embed-body"></div>')
      expect(file_viewer).to receive(:header_html).and_return('<div class="sul-embed-header"></div>')
      expect(file_viewer).to receive(:metadata_html).and_return('<div class="sul-embed-metadata-panel"></div>')
      expect(file_viewer).to receive(:footer_html).and_return('<div class="sul-embed-footer"></div>')
      html = Capybara.string(file_viewer.to_html)
      expect(html).to have_css '.sul-embed-container[style="display:none; max-height:200px; max-width:200px;"]', visible: false
    end
  end
  describe 'height/width' do
    it 'should set a default height and default width to nil (which can be overridden at the viewer level)' do
      stub_request(request)
      expect(file_viewer.send(:default_width)).to be_nil
    end
    it 'should use the incoming maxheight/maxwidth parameters from the request' do
      expect(request).to receive(:maxheight).at_least(:once).and_return(100)
      expect(request).to receive(:maxwidth).at_least(:once).and_return(200)
      stub_request(request)
      expect(file_viewer.height).to eq 100
      expect(file_viewer.width).to eq 200
    end
  end
end
