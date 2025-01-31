# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WasSeedComponent, type: :component do
  include WasTimeMapFixtures

  let(:embed_request) do
    Embed::Request.new(url: 'http://purl.stanford.edu/abc123', new_viewer: 'true')
  end
  let(:viewer) { Embed::Viewer::WasSeed.new(embed_request) }
  let(:purl) { build(:purl, :was_seed) }

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
  end

  context 'with current timemap behavior' do
    let(:fake_connection) do
      instance_double(Faraday::Connection, get: instance_double(Faraday::Response, body: timemap, success?: true))
    end

    before do
      allow_any_instance_of(Embed::WasTimeMap).to receive(:redirectable_connection).and_return(fake_connection)
      render_inline(described_class.new(viewer:))
    end

    it 'displays Was Seed viewer body' do
      # visible false because we display:none the container until we've loaded the CSS.
      expect(page).to have_content 'Stanford Web Archive Portal'
      expect(page).to have_content 'Captured 7 times between 18 July 2009 and 15 June 2011'
      expect(page).to have_css '.sul-embed-was-seed-list-item', visible: :all, count: 7
    end
  end

  context 'with new timemap behavior' do
    let(:fake_connection) do
      instance_double(Faraday::Connection, get: instance_double(Faraday::Response, body: timemap_new, success?: true))
    end

    before do
      allow_any_instance_of(Embed::WasTimeMap).to receive(:redirectable_connection).and_return(fake_connection)
      render_inline(described_class.new(viewer:))
    end

    it 'displays Was Seed viewer body' do
      # visible false because we display:none the container until we've loaded the CSS.
      expect(page).to have_content 'Stanford Web Archive Portal'
      expect(page).to have_content 'Captured 7 times between 18 July 2009 and 15 June 2011'
      expect(page).to have_css '.sul-embed-was-seed-list-item', visible: :all, count: 7
    end
  end
end
