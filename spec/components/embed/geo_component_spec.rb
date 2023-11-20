# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::GeoComponent, type: :component do
  include PurlFixtures

  let(:request) do
    Embed::Request.new(url: 'http://purl.stanford.edu/abc123')
  end
  let(:object) { Embed::Purl.find('12345') }
  let(:viewer) { Embed::Viewer::Geo.new(request) }

  before do
    allow(request).to receive(:purl_object).and_return(object)
    allow(viewer).to receive(:asset_host).and_return('http://example.com/')
    allow(object).to receive(:response).and_return(geo_purl_public)
    render_inline(described_class.new(viewer:))
  end

  it 'draws geo html body for public resources' do
    # expect(geo_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')

    # html = Capybara.string(geo_viewer.to_html)
    # visible false because we display:none the container until we've loaded the CSS.
    expect(page).to have_css '.sul-embed-geo', visible: :all
    expect(page).to have_css '#sul-embed-geo-map', visible: :all
    expect(page).to have_css('#sul-embed-geo-map[style="flex: 1"]', visible: :all)
    expect(page).to have_css('#sul-embed-geo-map[data-bounding-box=\'[["-1.478794", "29.572742"], ["4.234077", "35.000308"]]\']', visible: :all)
    expect(page).to have_css('#sul-embed-geo-map[data-wms-url="https://geowebservices.stanford.edu/geoserver/wms/"]', visible: :all)
    expect(page).to have_css('#sul-embed-geo-map[data-layers="druid:12345"]', visible: :all)
  end

  context 'with hidden title' do
    let(:request) do
      Embed::Request.new(url: 'http://purl.stanford.edu/abc123', hide_title: 'true')
    end

    it do
      expect(page).not_to have_css '.sul-embed-header', visible: :all
    end
  end
end
