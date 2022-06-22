# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'embed/template/_was_seed' do
  include PurlFixtures
  include WasTimeMapFixtures

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:object) { Embed::Purl.new('12345') }
  let(:viewer) { Embed::Viewer::WasSeed.new(request) }

  before do
    view.lookup_context.view_paths.push 'app/views/embed'
    expect(Faraday).to receive(:get).and_return(double('response', body: timemap, success?: true))
    allow(request).to receive(:purl_object).and_return(object)
    allow(object).to receive(:response).and_return(was_seed_purl)
    allow(viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')
    allow(view).to receive(:viewer).and_return(viewer)
  end

  it 'displays Was Seed viewer body' do
    render
    # visible false because we display:none the container until we've loaded the CSS.
    expect(rendered).to have_css '.sul-embed-was-seed', visible: :all
    expect(rendered).to have_css '.sul-embed-was-seed-list', visible: :all, count: 1
    expect(rendered).to have_css '.sul-embed-was-seed-list-item', visible: :all, count: 7
  end

  describe 'with hidden title' do
    it do
      allow(viewer).to receive(:display_header?).at_least(:once).and_return(false)
      render
      expect(rendered).not_to have_css '.sul-embed-header', visible: :all
    end
  end
end
