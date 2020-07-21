# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'embed/template/_geo.html.erb' do
  include PurlFixtures

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:object) { Embed::Purl.new('12345') }
  let(:viewer) { Embed::Viewer::Geo.new(request) }

  before do
    view.lookup_context.view_paths.push 'app/views/embed'
    allow(request).to receive(:purl_object).and_return(object)
    allow(viewer).to receive(:asset_host).and_return('http://example.com/')
    allow(view).to receive(:viewer).and_return(viewer)
    allow(object).to receive(:response).and_return(geo_purl_public)
  end

  it 'draws geo html body for public resources' do
    render
    # expect(geo_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')

    # html = Capybara.string(geo_viewer.to_html)
    # visible false because we display:none the container until we've loaded the CSS.
    expect(rendered).to have_css '.sul-embed-geo', visible: false
    expect(rendered).to have_css '#sul-embed-geo-map', visible: false
    expect(rendered).to have_css('#sul-embed-geo-map[style="flex: 1"]', visible: false)
    expect(rendered).to have_css('#sul-embed-geo-map[data-bounding-box=\'[["-1.478794", "29.572742"], ["4.234077", "35.000308"]]\']', visible: false)
    expect(rendered).to have_css('#sul-embed-geo-map[data-wms-url="https://geowebservices.stanford.edu/geoserver/wms/"]', visible: false)
    expect(rendered).to have_css('#sul-embed-geo-map[data-layers="druid:12345"]', visible: false)
  end

  describe 'with hidden title' do
    it do
      allow(viewer).to receive(:display_header?).at_least(:once).and_return(false)
      render
      expect(rendered).to_not have_css '.sul-embed-header', visible: false
    end
  end
end
