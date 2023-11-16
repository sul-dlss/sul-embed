# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::FileComponent, type: :component do
  include PurlFixtures

  let(:request) do
    Embed::Request.new(url: 'http://purl.stanford.edu/abc123')
  end
  let(:object) { Embed::Purl.new('12345') }
  let(:viewer) { Embed::Viewer::File.new(request) }
  let(:response) { file_purl_xml }

  before do
    allow(request).to receive(:purl_object).and_return(object)
    allow(viewer).to receive(:asset_host).and_return('http://example.com/')
    allow(object).to receive(:response).and_return(response)
    render_inline(described_class.new(viewer:))
  end

  it 'returns html that has header, body, and footer wrapped in a container' do
    # visible :all because we display:none the container until we've loaded the CSS.
    expect(page).to have_css 'div.sul-embed-container', visible: :all
    expect(page).to have_css 'div.sul-embed-body', visible: :all
    expect(page).to have_css 'div.sul-embed-header', visible: :all
    expect(page).to have_css 'div.sul-embed-panel-container', visible: :all
    expect(page).to have_css 'div.sul-embed-footer', visible: :all
  end

  describe 'multi_resource_multi_type_purl' do
    let(:response) { multi_resource_multi_type_purl }

    it 'returns a table of files' do
      # visible :all because we display:none the container until we've loaded the CSS.
      expect(page).to have_css '.sul-embed-file-list', visible: :all
      expect(page).to have_css 'a[download]', visible: :all, text: '12.35 kB'
    end

    it 'have the appropriate attributes for being _blank' do
      expect(page).to have_css('.sul-embed-media-heading a[target="_blank"][rel="noopener noreferrer"]', visible: :all)
      expect(page).to have_css('.sul-embed-download a[target="_blank"][rel="noopener noreferrer"]', visible: :all)
    end
  end

  context 'when file size is zero' do
    let(:response) { image_no_size_purl }

    it 'displays Download as the link text' do
      expect(page).to have_css 'a[download]', visible: :all, text: /Download$/
    end
  end

  context 'with empty file size' do
    let(:response) { image_empty_size_purl }

    it 'displays Download as the link text' do
      expect(page).to have_css 'a[download]', visible: :all, text: /Download$/
    end
  end

  describe 'embargo/Stanford only' do
    let(:response) { embargoed_stanford_file_purl_xml }

    it 'adds a Stanford specific embargo message with links still present' do
      expect(page).to have_css('.sul-embed-embargo-message', visible: :all, text: "Access is restricted to Stanford-affiliated patrons until #{1.month.from_now.strftime('%d-%b-%Y')}")
      expect(page).to have_css('.sul-embed-media-heading a[href="https://stacks.stanford.edu/file/druid:12345/Title%20of%20the%20PDF.pdf"]', visible: :all)
    end

    it 'includes an element with a stanford icon class (with screen reader text)' do
      expect(page).to have_css(
        '.sul-embed-media-heading .sul-embed-stanford-only-text .sul-embed-text-hide',
        visible: :all,
        text: 'Stanford only'
      )
    end
  end

  describe 'embargoed to world' do
    let(:response) { embargoed_file_purl_xml }

    it 'adds a generalized embargo message and no links are present' do
      expect(page).to have_css('.sul-embed-embargo-message', visible: :all, text: "Access is restricted until #{1.month.from_now.strftime('%d-%b-%Y')}")
      # FIXME: this is a bad spec as it's not checking for visibility false
      expect(page).not_to have_link
    end
  end

  describe 'location restricted' do
    let(:response) { single_video_purl }

    it 'includes text indicating the file is location restricted' do
      expect(page).to have_css('.sul-embed-media-heading .sul-embed-location-restricted-text', visible: :all, text: '(Restricted)')
    end
  end

  context 'with hidden title' do
    let(:request) do
      Embed::Request.new(url: 'http://purl.stanford.edu/abc123', hide_title: 'true')
    end

    it do
      allow(viewer).to receive(:display_header?).at_least(:once).and_return(false)
      expect(page).not_to have_css '.sul-embed-header', visible: :all
    end
  end
end
