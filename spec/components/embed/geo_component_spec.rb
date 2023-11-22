# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::GeoComponent, type: :component do
  include PurlFixtures

  let(:request) do
    Embed::Request.new(url: 'http://purl.stanford.edu/abc123')
  end
  let(:viewer) { Embed::Viewer::Geo.new(request) }

  before do
    stub_purl_xml_response_with_fixture(geo_purl_public)
    render_inline(described_class.new(viewer:))
  end

  it 'draws geo html body for public resources' do
    # visible false because we display:none the container until we've loaded the CSS.
    expect(page).to have_css '.sul-embed-geo', visible: :all
    expect(page).to have_css '#sul-embed-geo-map', visible: :all
    expect(page).to have_css('#sul-embed-geo-map[style="flex: 1"]', visible: :all)
    expect(page).to have_css('#sul-embed-geo-map[data-bounding-box=\'[["-1.478794", "29.572742"], ["4.234077", "35.000308"]]\']', visible: :all)
    expect(page).to have_css('#sul-embed-geo-map[data-wms-url="https://geowebservices.stanford.edu/geoserver/wms/"]', visible: :all)
    expect(page).to have_css('#sul-embed-geo-map[data-layers="druid:abc123"]', visible: :all)
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
