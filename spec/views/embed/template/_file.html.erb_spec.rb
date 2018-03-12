require 'rails_helper'

RSpec.describe 'embed/template/_file.html.erb' do
  include PURLFixtures

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:object) { Embed::PURL.new('12345') }
  let(:viewer) { Embed::Viewer::File.new(request) }
  let(:response) { file_purl }

  before do
    view.lookup_context.view_paths.push 'app/views/embed'
    allow(request).to receive(:purl_object).and_return(object)
    allow(viewer).to receive(:asset_host).and_return('http://example.com/')
    allow(view).to receive(:viewer).and_return(viewer)
    allow(object).to receive(:response).and_return(response)
  end

  it 'returns html that has header, body, and footer wrapped in a container' do
    stub_template 'body/_file.html.erb' => '<div class="sul-embed-body"></div>'
    stub_template 'header/_file.html.erb' => '<div class="sul-embed-header"></div>'
    stub_template '_metadata_panel.html.erb' => '<div class="ul-embed-panel-container"></div>'
    stub_template 'footer/_generic.html.erb' => '<div class="sul-embed-footer"></div>'

    render
    # visible false because we display:none the container until we've loaded the CSS.
    expect(rendered).to have_css 'div.sul-embed-container', visible: false
    expect(rendered).to have_css 'div.sul-embed-body', visible: false
    expect(rendered).to have_css 'div.sul-embed-header', visible: false
    expect(rendered).to have_css 'div.sul-embed-panel-container', visible: false
    expect(rendered).to have_css 'div.sul-embed-footer', visible: false
  end
  it 'includes the height/width style in the container if maxheight/width is passed' do
    allow(request).to receive(:maxheight).at_least(:once).and_return(200)
    allow(request).to receive(:maxwidth).at_least(:once).and_return(200)
    render

    stub_template 'body/_file.html.erb' => '<div class="sul-embed-body"></div>'
    stub_template 'header/_file.html.erb' => '<div class="sul-embed-header"></div>'
    stub_template '_metadata_panel.html.erb' => '<div class="ul-embed-panel-container"></div>'
    stub_template 'footer/_generic.html.erb' => '<div class="sul-embed-footer"></div>'
    expect(rendered).to have_css '.sul-embed-container[style="display:none; max-height:200px; max-width:200px;"]', visible: false
  end

  context 'when the fullheight option is passed' do
    it 'includes the sul-embed-fullheight class' do
      allow(request).to receive(:fullheight?).at_least(:once).and_return(true)
      render
      expect(rendered).to have_css('.sul-embed-fullheight[style="display:none; max-height:100%; max-width:100%;"]', visible: false)
    end
  end

  context 'multi_resource_multi_type_purl' do
    let(:response) { multi_resource_multi_type_purl }
    before { render }
    it 'returns a table of files' do
      # expect(file_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')
      # visible false because we display:none the container until we've loaded the CSS.
      expect(rendered).to have_css '.sul-embed-file-list', visible: false
      expect(rendered).to have_css 'a[download]', visible: false, text: '12.35 kB'
    end

    it 'have the appropriate attributes for being _blank' do
      # expect(file_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')
      expect(rendered).to have_css('.sul-embed-media-heading a[target="_blank"][rel="noopener noreferrer"]', visible: false)
      expect(rendered).to have_css('.sul-embed-download a[target="_blank"][rel="noopener noreferrer"]', visible: false)
    end
  end

  context 'without file size' do
    let(:response) { image_no_size_purl }
    before { render }

    it 'displays Download as the link text' do
      # expect(file_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')
      expect(rendered).to have_css 'a[download]', visible: false, text: /Download$/
    end
  end
  context 'with empty file size' do
    let(:response) { image_empty_size_purl }
    before { render }

    it 'displays Download as the link text' do
      # expect(file_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')
      expect(rendered).to have_css 'a[download]', visible: false, text: /Download$/
    end
  end

  describe 'embargo/Stanford only' do
    let(:response) { embargoed_stanford_file_purl }
    before { render }

    it 'adds a Stanford specific embargo message with links still present' do
      # ?expect(file_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com')
      expect(rendered).to have_css('.sul-embed-embargo-message', visible: false, text: "Access is restricted to Stanford-affiliated patrons until #{(Time.current + 1.month).strftime('%d-%b-%Y')}")
      expect(rendered).to have_css('.sul-embed-media-heading a[href="https://stacks.stanford.edu/file/druid:12345/Title%20of%20the%20PDF.pdf"]', visible: false)
    end

    it 'includes an element with a stanford icon class (with screen reader text)' do
      # expect(file_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com')
      expect(rendered).to have_css(
        '.sul-embed-media-heading .sul-embed-stanford-only-text .sul-embed-text-hide',
        visible: false,
        text: 'Stanford only'
      )
    end
  end
  describe 'embargoed to world' do
    let(:response) { embargoed_file_purl }
    before { render }

    it 'adds a generalized embargo message and no links are present' do
      expect(rendered).to have_css('.sul-embed-embargo-message', visible: false, text: "Access is restricted until #{(Time.current + 1.month).strftime('%d-%b-%Y')}")
      # FIXME: this is a bad spec as it's not checking for visibility false
      expect(rendered).not_to have_css('a')
    end
  end

  describe 'location restricted' do
    let(:response) { single_video_purl }
    before { render }
    it 'includes text indicating the file is location restricted' do
      expect(rendered).to have_css('.sul-embed-media-heading .sul-embed-location-restricted-text', visible: false, text: '(Restricted)')
    end
  end

  describe 'with hidden title' do
    it do
      allow(viewer).to receive(:display_header?).at_least(:once).and_return(false)
      render
      expect(rendered).to_not have_css '.sul-embed-header', visible: false
    end
  end
end
