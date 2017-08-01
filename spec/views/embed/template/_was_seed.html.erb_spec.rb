require 'rails_helper'

RSpec.describe 'embed/template/_was_seed.html.erb' do
  include PURLFixtures
  include WasSeedThumbsFixtures

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:object) { Embed::PURL.new('12345') }
  let(:viewer) { Embed::Viewer::WasSeed.new(request) }

  before do
    view.lookup_context.view_paths.push 'app/views/embed'
    allow(request).to receive(:purl_object).and_return(object)
    allow(object).to receive(:response).and_return(was_seed_purl)
    allow(viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')
    allow(viewer).to receive(:thumbs_list).and_return(thumbs_list_fixtures)
    allow(view).to receive(:viewer).and_return(viewer)
  end

  it 'displays Was Seed viewer body' do
    render
    # visible false because we display:none the container until we've loaded the CSS.
    expect(rendered).to have_css '.sul-embed-was-seed', visible: false
    expect(rendered).to have_css '.sul-embed-was-thumb-list', visible: false, count: 1
    expect(rendered).to have_css '.sul-embed-was-thumb-item', visible: false, count: 4
    expect(rendered).to have_css '.sul-embed-was-thumb-item-div', visible: false, count: 4
    expect(rendered).to have_css '.sul-embed-was-thumb-item-div[style="height: 200px; width: 200px;"]', visible: false, count: 4
    expect(rendered).to have_css '.sul-embed-was-seed[data-sul-thumbs-list-count="4"]', visible: false

    expect(rendered).to have_css '.sul-embed-was-thumb-item-div a[href="https://swap.stanford.edu/20121129060351/http://naca.central.cranfield.ac.uk/"]', visible: false
    expect(rendered).to have_css '.sul-embed-was-thumb-item-date', text: '29-Nov-2012', visible: false
    expect(rendered).to have_css '.sul-embed-was-thumb-item img[src="https://stacks.stanford.edu/image/iiif/gb089bd2251%2F20121129060351/full/200,/0/default.jpg"]', visible: false

    expect(rendered).to have_css '.sul-embed-was-thumb-item img[style="height: 176px;"]', visible: false

    expect(rendered).to have_css '.sul-embed-was-thumb-item-div a[href="https://swap.stanford.edu/20130412231301/http://naca.central.cranfield.ac.uk/"]', visible: false
    expect(rendered).to have_css '.sul-embed-was-thumb-item-date', text: '12-Apr-2013', visible: false
    expect(rendered).to have_css '.sul-embed-was-thumb-item img[src="https://stacks.stanford.edu/image/iiif/gb089bd2251%2F20130412231301/full/200,/0/default.jpg"]', visible: false
  end

  describe 'with hidden title' do
    it do
      allow(viewer).to receive(:display_header?).at_least(:once).and_return(false)
      render
      expect(rendered).to_not have_css '.sul-embed-header', visible: false
    end
  end
end
