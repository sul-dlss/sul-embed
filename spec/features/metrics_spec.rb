# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'metrics tracking', :js do
  before do
    allow(Settings).to receive(:metrics_api_url).and_return('/test_metrics_api')
    allow(Embed::Purl).to receive(:find).and_return(purl)
    StubMetricsApi.reset!
  end

  describe 'iiif viewer' do
    let(:purl) { nil }

    context 'with a purl manifest' do
      let(:druid) { 'fr426cg9537' }

      before do
        stub_request(:get, 'https://purl.stanford.edu/fr426cg9537.xml')
      end

      it 'tracks views' do
        visit iiif_path(url: 'https://purl.stanford.edu/fr426cg9537/iiif/manifest')
        wait_for_view
        expect(StubMetricsApi.last_event).to match(view_with_properties('druid' => druid))
      end
    end

    context 'with an external manifest' do
      let(:druid) { 'wz026zp2442' }

      it 'tracks views' do
        visit iiif_path(url: 'https://dms-data.stanford.edu/data/manifests/Parker/wz026zp2442/manifest.json')
        wait_for_view
        expect(StubMetricsApi.last_event).to match(view_with_properties('druid' => druid))
      end
    end
  end

  describe 'media viewer' do
    let(:druid) { 'bc123df4567' }
    let(:purl) { build(:purl, :video, druid:) }

    it 'tracks views' do
      visit_iframe_response(druid)
      wait_for_view
      expect(StubMetricsApi.last_event).to match(view_with_properties('druid' => druid))
    end
  end

  describe 'leaflet viewer' do
    let(:druid) { 'cz128vq0535' }
    let(:purl) { build(:purl, :geo, druid:) }

    it 'tracks views' do
      visit_iframe_response(druid)
      wait_for_view
      expect(StubMetricsApi.last_event).to match(view_with_properties('druid' => druid))
    end
  end

  describe 'pdf viewer' do
    let(:druid) { 'bc123df4567' }
    let(:purl) { build(:purl, :document, druid:) }

    it 'tracks views' do
      visit_iframe_response(druid)
      wait_for_view
      expect(StubMetricsApi.last_event).to match(view_with_properties('druid' => druid))
    end
  end

  describe 'web archive viewer' do
    let(:druid) { 'bc123df4567' }
    let(:purl) { build(:purl, :was_seed, druid:) }

    before do
      stub_request(:get, 'https://swap.stanford.edu/timemap/http://naca.central.cranfield.ac.uk/')
    end

    it 'tracks views' do
      visit_iframe_response(druid)
      wait_for_view
      expect(StubMetricsApi.last_event).to match(view_with_properties('druid' => druid))
    end
  end

  describe '3d viewer' do
    let(:druid) { 'qf794pv6287' }
    let(:purl) { build(:purl, :model_3d, druid:) }

    it 'tracks views' do
      visit_iframe_response(druid)
      wait_for_view
      expect(StubMetricsApi.last_event).to match(view_with_properties('druid' => druid))
    end
  end

  describe 'file viewer' do
    let(:druid) { 'bc123df4567' }
    let(:purl) { build(:purl, :file, druid:) }

    it 'tracks views' do
      visit_iframe_response(druid)
      wait_for_view
      expect(StubMetricsApi.last_event).to match(view_with_properties('druid' => druid))
    end
  end
end
