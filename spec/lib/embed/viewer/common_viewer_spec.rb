require 'rails_helper'

describe Embed::Viewer::CommonViewer do
  include PURLFixtures
  let(:rails_request) { double('rails_request', host_with_port: '') }
  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:file_viewer) { Embed::Viewer::File.new(request) }
  let(:image_x_viewer) { Embed::Viewer::ImageX.new(request) }
  let(:geo_viewer) { Embed::Viewer::Geo.new(request) }
  let(:media_viewer) { Embed::Viewer::Media.new(request) }
  let(:was_seed_viewer) { Embed::Viewer::WasSeed.new(request) }

  before do
    allow(request).to receive(:rails_request).and_return(rails_request)
  end

  describe 'header_html' do
    it "returns the object's title" do
      expect(request).to receive(:params).at_least(:once).and_return({})
      expect(request).to receive(:hide_title?).at_least(:once).and_return(false)
      stub_purl_response_and_request(file_purl, request)
      html = Capybara.string(file_viewer.header_html)
      expect(html).to have_css '.sul-embed-header-title', text: 'File Title'
    end
    it 'does not return the object title if the consumer requested to hide it' do
      expect(request).to receive(:params).at_least(:once).and_return({})
      expect(request).to receive(:hide_title?).at_least(:once).and_return(true)
      stub_purl_response_and_request(file_purl, request)
      html = Capybara.string(file_viewer.header_html)
      expect(html).to_not have_css '.sul-embed-header-title'
      expect(html).to_not have_css '.sul-embed-metadata-title'
    end
  end
  describe 'metadata_html' do
    it 'has metadata panel html' do
      stub_purl_response_and_request(file_purl, request)
      html = Capybara.string(file_viewer.metadata_html)
      expect(html).to have_css 'div.sul-embed-panel-container'
      expect(html).to have_css 'div.sul-embed-metadata-panel', visible: false
    end
    it 'has use and reproduction statement' do
      stub_purl_response_and_request(file_purl, request)
      html = Capybara.string(file_viewer.metadata_html)
      expect(html).to have_content 'Use and reproduction'
    end
    it 'does not have use and reproduction when not in object' do
      stub_purl_response_and_request(image_purl, request)
      html = Capybara.string(image_x_viewer.metadata_html)
      expect(html).to_not have_content 'Use and reproduction'
    end
    it 'has copyright' do
      stub_purl_response_and_request(image_purl, request)
      html = Capybara.string(image_x_viewer.metadata_html)
      expect(html).to have_content 'Copyright'
    end
    it 'does not have copyright when not in object' do
      stub_purl_response_and_request(file_purl, request)
      html = Capybara.string(file_viewer.metadata_html)
      expect(html).to_not have_content 'Copyright'
    end
    it 'has license' do
      stub_purl_response_and_request(file_purl, request)
      html = Capybara.string(file_viewer.metadata_html)
      expect(html).to have_content 'License'
    end
    it 'does not have license when not in object' do
      stub_purl_response_and_request(image_purl, request)
      html = Capybara.string(image_x_viewer.metadata_html)
      expect(html).to_not have_content 'License'
    end
    it 'does not return the metadata panel at all if hidden' do
      expect(request).to receive(:hide_metadata?).at_least(:once).and_return(true)
      stub_request(request)
      html = Capybara.string(file_viewer.metadata_html)
      expect(html).to_not have_css '.sul-embed-metadata-container'
      expect(html).to_not have_css '[data-sul-embed-toggle="sul-embed-metadata-panel"]'
    end
  end
  describe 'footer_html' do
    it "returns the object's footer" do
      html = Capybara.string(image_x_viewer.footer_html)
      expect(html).to have_css 'div.sul-embed-footer'
      expect(html).to have_css '[aria-label="open embed this panel"]'
      expect(html).to have_css '[aria-label="open download panel"]'
    end
    # note: download panel is tested in features/download_panel_spec
  end
  describe 'to_html' do
    it 'returns html that has header, body, and footer wrapped in a container' do
      stub_purl_response_and_request(file_purl, request)
      expect(file_viewer).to receive(:body_html).and_return('<div class="sul-embed-body"></div>')
      expect(file_viewer).to receive(:header_html).and_return('<div class="sul-embed-header"></div>')
      expect(file_viewer).to receive(:metadata_html).and_return('<div class="sul-embed-panel-container"></div>')
      expect(file_viewer).to receive(:footer_html).and_return('<div class="sul-embed-footer"></div>')
      html = Capybara.string(file_viewer.to_html)
      # visible false because we display:none the container until we've loaded the CSS.
      expect(html).to have_css 'div.sul-embed-container', visible: false
      expect(html).to have_css 'div.sul-embed-body', visible: false
      expect(html).to have_css 'div.sul-embed-header', visible: false
      expect(html).to have_css 'div.sul-embed-panel-container', visible: false
      expect(html).to have_css 'div.sul-embed-footer', visible: false
    end
    it 'includes the height/width style in the container if maxheight/width is passed' do
      expect(request).to receive(:maxheight).at_least(:once).and_return(200)
      expect(request).to receive(:maxwidth).at_least(:once).and_return(200)
      stub_purl_response_and_request(file_purl, request)
      expect(file_viewer).to receive(:body_html).and_return('<div class="sul-embed-body"></div>')
      expect(file_viewer).to receive(:header_html).and_return('<div class="sul-embed-header"></div>')
      expect(file_viewer).to receive(:metadata_html).and_return('<div class="sul-embed-metadata-panel"></div>')
      expect(file_viewer).to receive(:footer_html).and_return('<div class="sul-embed-footer"></div>')
      html = Capybara.string(file_viewer.to_html)
      expect(html).to have_css '.sul-embed-container[style="display:none; max-height:200px; max-width:200px;"]', visible: false
    end
  end
  describe 'height/width' do
    it 'sets a default height and default width to nil (which can be overridden at the viewer level)' do
      stub_request(request)
      expect(file_viewer.send(:default_width)).to be_nil
    end
    it 'uses the incoming maxheight/maxwidth parameters from the request' do
      expect(request).to receive(:maxheight).at_least(:once).and_return(100)
      expect(request).to receive(:maxwidth).at_least(:once).and_return(200)
      stub_request(request)
      expect(file_viewer.height).to eq 100
      expect(file_viewer.width).to eq 200
    end
  end
  describe 'external_url' do
    it 'returns nil' do
      expect(request).to receive(:purl_object).and_return(nil)
      common_viewer = Embed::Viewer::CommonViewer.new(request)
      expect(common_viewer.external_url).to be_nil
    end
  end
  describe '#file_url' do
    it 'creates a stacks file url' do
      expect(file_viewer.file_url('cool_file')).to eq 'https://stacks.stanford.edu/file/druid:abc123/cool_file'
    end
  end

  describe '#sul_pretty_date' do
    it 'parses a date into a standardized format' do
      expect(file_viewer.sul_pretty_date(Time.zone.now.to_s)).to match(/^\d{2}-\w{3}-\d{4}$/)
    end
    it 'checks for a blank string' do
      expect(file_viewer.sul_pretty_date(nil)).to be_nil
    end
  end

  describe '#show_download?' do
    it 'not shown for file viewers' do
      expect(file_viewer.show_download?).to be_falsey
    end
    it 'shown for image and geo viewer' do
      expect(image_x_viewer.show_download?).to be_truthy
      expect(geo_viewer.show_download?).to be_truthy
    end
    it 'not shown when hide_download is specified' do
      hide_request = Embed::Request.new(url: 'http://purl.stanford.edu/abc123',
                                        hide_download: 'true')
      geo_hide_viewer = Embed::Viewer::Geo.new(hide_request)
      expect(geo_hide_viewer.show_download?).to be_falsey
    end
  end
  describe '#show_download_count?' do
    it 'false for image_x viewer' do
      expect(image_x_viewer.show_download_count?).to be_falsey
    end
    it 'true for non-image viewers' do
      expect(file_viewer.show_download_count?).to be_truthy
      expect(geo_viewer.show_download_count?).to be_truthy
      expect(media_viewer.show_download_count?).to be_truthy
      expect(was_seed_viewer.show_download_count?).to be_truthy
    end
  end

  describe '#body_height' do
    it 'is the default_body_height when no maxheight is provided' do
      expect(file_viewer).to receive(:default_body_height).and_return(200)
      expect(file_viewer.body_height).to eq 200
    end

    it 'subtracts the header and footer height' do
      expect(request).to receive(:maxheight).at_least(:once).and_return(200)
      expect(file_viewer.body_height).to be < 200
    end
  end
end
