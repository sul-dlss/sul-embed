# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'embed/template/_m3_viewer' do
  include PurlFixtures

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123', canvas_index: 3, search: 'xyz', suggested_search: 'abc') }
  let(:object) { Embed::Purl.new('12345') }
  let(:viewer) { Embed::Viewer::M3Viewer.new(request) }

  before do
    view.lookup_context.view_paths.push 'app/views/embed'
    allow(request).to receive(:purl_object).and_return(object)
    allow(viewer).to receive(:asset_host).and_return('http://example.com/')
    allow(view).to receive(:viewer).and_return(viewer)
    allow(object).to receive(:response).and_return(image_purl)
  end

  it 'adds m3 html body for resources' do
    render
    expect(rendered).to have_css '#sul-embed-m3', visible: false
  end

  describe 'with hidden title' do
    it do
      allow(viewer).to receive(:display_header?).at_least(:once).and_return(false)
      render
      expect(rendered).to_not have_css '.sul-embed-header', visible: false
    end
  end

  it 'passes along canvas index' do
    render
    expect(rendered).to have_css '[data-canvas-index="3"]', visible: false
  end

  it 'passes along seeded search queries' do
    render
    expect(rendered).to have_css '[data-search="xyz"]', visible: false
    expect(rendered).to have_css '[data-suggested-search="abc"]', visible: false
  end
end
