# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::WasSeedComponent, type: :component do
  include PurlFixtures
  include WasTimeMapFixtures

  let(:request) do
    Embed::Request.new(url: 'http://purl.stanford.edu/abc123')
  end
  let(:object) { Embed::Purl.new('12345') }
  let(:viewer) { Embed::Viewer::WasSeed.new(request) }

  context 'with current timemap behavior' do
    let(:fake_connection) do
      instance_double(Faraday::Connection, get: instance_double(Faraday::Response, body: timemap, success?: true))
    end

    before do
      allow_any_instance_of(Embed::WasTimeMap).to receive(:redirectable_connection).and_return(fake_connection)
      expect(fake_connection).to receive(:get).once
      allow(request).to receive(:purl_object).and_return(object)
      allow(object).to receive(:response).and_return(was_seed_purl)
      allow(viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')
      render_inline(described_class.new(viewer:))
    end

    it 'displays Was Seed viewer body' do
      # visible false because we display:none the container until we've loaded the CSS.
      expect(page).to have_css '.sul-embed-was-seed', visible: :all
      expect(page).to have_css '.sul-embed-was-seed-list', visible: :all, count: 1
      expect(page).to have_css '.sul-embed-was-seed-list-item', visible: :all, count: 7
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

  context 'with new timemap behavior' do
    let(:fake_connection) do
      instance_double(Faraday::Connection, get: instance_double(Faraday::Response, body: timemap_new, success?: true))
    end

    before do
      allow_any_instance_of(Embed::WasTimeMap).to receive(:redirectable_connection).and_return(fake_connection)
      expect(fake_connection).to receive(:get).once
      allow(request).to receive(:purl_object).and_return(object)
      allow(object).to receive(:response).and_return(was_seed_purl)
      allow(viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')
      render_inline(described_class.new(viewer:))
    end

    it 'displays Was Seed viewer body' do
      # visible false because we display:none the container until we've loaded the CSS.
      expect(page).to have_css '.sul-embed-was-seed', visible: :all
      expect(page).to have_css '.sul-embed-was-seed-list', visible: :all, count: 1
      expect(page).to have_css '.sul-embed-was-seed-list-item', visible: :all, count: 7
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
end
