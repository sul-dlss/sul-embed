# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MiradorComponent, type: :component do
  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123', canvas_index: 3, search: 'xyz', suggested_search: 'abc') }
  let(:viewer) { Embed::Viewer::MiradorViewer.new(request) }
  let(:purl) { build(:purl) }

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
    render_inline(described_class.new(viewer:))
  end

  it 'adds mirador html body for resources' do
    expect(page).to have_css '#sul-embed-mirador', visible: :all
  end

  it 'passes along canvas index' do
    expect(page).to have_css '[data-canvas-index="3"]', visible: :all
  end

  it 'passes along seeded search queries' do
    expect(page).to have_css '[data-search="xyz"]', visible: :all
    expect(page).to have_css '[data-suggested-search="abc"]', visible: :all
  end

  it 'offers no map viewer to an object with nothing to put on a map' do
    expect(page).to have_css '#sul-embed-mirador[data-georeference-url=""]', visible: :all
    expect(page).to have_css '#sul-embed-mirador[data-view-labels=""]', visible: :all
  end

  context 'when the object carries a georeference annotation' do
    let(:purl) { build(:purl, :georeferenced_map) }

    it 'passes along everything the map view needs' do
      expect(page).to have_css(
        '#sul-embed-mirador[data-georeference-url="https://stacks.stanford.edu/file/bb013fz9675/bb013fz9675_0001.json"]',
        visible: :all
      )
      expect(page).to have_css(
        '#sul-embed-mirador[data-iiif3-manifest="https://purl.stanford.edu/bb013fz9675/iiif3/manifest"]',
        visible: :all
      )
      expect(page).to have_css(
        "#sul-embed-mirador[data-view-labels='#{I18n.t('viewers.mirador_viewer.views').to_json}']",
        visible: :all
      )
    end
  end
end
