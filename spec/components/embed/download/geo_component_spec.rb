# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Download::GeoComponent, type: :component do
  include PurlFixtures

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:object) { Embed::Purl.find('12345') }
  let(:viewer) { Embed::Viewer::Geo.new(request) }
  let(:response) { geo_purl_public }

  before do
    allow(request).to receive(:purl_object).and_return(object)
    allow(viewer).to receive(:asset_host).and_return('http://example.com/')
    allow(object).to receive(:response).and_return(response)
    render_inline(described_class.new(viewer:))
  end

  context 'when hide_download' do
    let(:viewer) do
      Embed::Viewer::Geo.new(
        Embed::Request.new(
          url: 'http://purl.stanford.edu/abc123', hide_download: 'true'
        )
      )
    end

    it 'is empty' do
      expect(page).not_to have_css('body')
    end
  end

  it 'generates a file list when file has resources' do
    expect(page).to have_css 'li', visible: :all, count: 3
    expect(page).to have_link href: 'https://stacks.stanford.edu/file/druid:12345/data.zip?download=true', visible: :all
  end

  context 'with stanford only' do
    let(:response) { stanford_restricted_multi_file_purl_xml }

    it 'has the stanford-only class (with screen reader text)' do
      expect(page).to have_css 'li .sul-embed-stanford-only-text .sul-embed-text-hide', text: 'Stanford only', visible: :all
    end
  end

  context 'with location restrictions' do
    let(:response) { single_video_purl }

    it 'includes text to indicate that they are restricted' do
      expect(page).to have_css 'li .sul-embed-location-restricted-text', text: '(Restricted)', visible: :all
    end
  end
end
