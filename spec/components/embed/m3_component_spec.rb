# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::M3Component, type: :component do
  include PurlFixtures

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123', canvas_index: 3, search: 'xyz', suggested_search: 'abc') }
  let(:object) { Embed::Purl.find('12345') }
  let(:viewer) { Embed::Viewer::M3Viewer.new(request) }

  before do
    allow(request).to receive(:purl_object).and_return(object)
    allow(viewer).to receive(:asset_host).and_return('http://example.com/')
    allow(object).to receive(:response).and_return(image_purl_xml)
    render_inline(described_class.new(viewer:))
  end

  it 'adds m3 html body for resources' do
    expect(page).to have_css '#sul-embed-m3', visible: :all
  end

  context 'with hidden title' do
    let(:request) do
      Embed::Request.new(url: 'http://purl.stanford.edu/abc123', hide_title: 'true')
    end

    it do
      expect(page).not_to have_css '.sul-embed-header', visible: :all
    end
  end

  it 'passes along canvas index' do
    expect(page).to have_css '[data-canvas-index="3"]', visible: :all
  end

  it 'passes along seeded search queries' do
    expect(page).to have_css '[data-search="xyz"]', visible: :all
    expect(page).to have_css '[data-suggested-search="abc"]', visible: :all
  end
end
