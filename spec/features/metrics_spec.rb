# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'metrics tracking', :js do
  before do
    allow(Settings).to receive(:metrics_api_url).and_return('/test_metrics_api')
    allow(Embed::Purl).to receive(:find).and_return(purl)
    StubMetricsApi.reset!
  end

  after do
    FileUtils.rm_rf(TEST_DOWNLOAD_DIR)
  end

  describe 'iiif viewer' do
    let(:purl) { nil }
    let(:druid) { 'fr426cg9537' }

    before do
      stub_request(:get, 'https://purl.stanford.edu/fr426cg9537.xml')
    end

    it 'tracks views' do
      visit iiif_path(url: 'https://purl.stanford.edu/fr426cg9537/iiif/manifest')
      wait_for_view
      expect(StubMetricsApi.last_event).to match(view_with_properties('druid' => druid))
    end

    it 'tracks file downloads', skip: 'needs mirador plugin?' do
      visit iiif_path(url: 'https://purl.stanford.edu/fr426cg9537/iiif/manifest')
      click_button 'Share & download'
      find('.MuiListItem-button', text: 'Download').click
      click_link 'Whole image (400 x 272px)'
      wait_for_download
      expect(StubMetricsApi.last_event).to match(
        download_with_properties(
          'druid' => druid,
          'file' => 'SC1094_s3_b14_f17_Cats_1976_0005/full/400,/0/default.jpg'
        )
      )
    end
  end

  describe 'media viewer' do
    let(:druid) { 'bc123df4567' }
    let(:purl) do
      build(:purl, :video, contents: [
              build(:resource, :video, files: [
                      build(:resource_file, :video, :world_downloadable, druid:)
                    ])
            ], druid:)
    end

    before do
      allow(Settings.enabled_features).to receive(:new_component).and_return(true)
    end

    it 'tracks views' do
      visit_iframe_response(druid)
      wait_for_view
      expect(StubMetricsApi.last_event).to match(view_with_properties('druid' => druid))
    end

    it 'tracks file downloads' do
      visit_iframe_response(druid)
      click_button 'Share and Download'
      click_button 'Download'
      click_link 'Download First Video'
      wait_for_download
      expect(StubMetricsApi.last_event).to match(download_with_properties('druid' => druid, 'file' => 'abc_123.mp4'))
    end
  end

  describe 'leaflet viewer' do
    let(:druid) { 'cz128vq0535' }
    let(:purl) do
      build(:purl, :geo, contents: [
              build(:resource, :file, files: [
                      build(:resource_file, :world_downloadable, druid:)
                    ])
            ], druid:)
    end

    it 'tracks views' do
      visit_iframe_response(druid)
      wait_for_view
      expect(StubMetricsApi.last_event).to match(view_with_properties('druid' => druid))
    end

    it 'tracks file downloads' do
      visit_iframe_response(druid)
      click_button '1 file available for download'
      click_link 'Download data.zip'
      wait_for_download
      expect(StubMetricsApi.last_event).to match(
        download_with_properties(
          'druid' => druid,
          'file' => 'data.zip'
        )
      )
    end
  end

  describe 'pdf viewer' do
    let(:druid) { 'bc123df4567' }
    let(:purl) do
      build(:purl, :document, contents: [
              build(:resource, :document, files: [
                      build(:resource_file, :document, :world_downloadable, druid:)
                    ])
            ], druid:)
    end

    it 'tracks views' do
      visit_iframe_response(druid)
      wait_for_view
      expect(StubMetricsApi.last_event).to match(view_with_properties('druid' => druid))
    end

    it 'tracks file downloads' do
      visit_iframe_response(druid)
      click_button '1 file available for download'
      click_link 'Download Title of the PDF.pdf'
      wait_for_download
      expect(StubMetricsApi.last_event).to match(
        download_with_properties(
          'druid' => druid,
          'file' => 'Title%20of%20the%20PDF.pdf'
        )
      )
    end
  end

  describe 'web archive viewer' do
    let(:druid) { 'bc123df4567' }
    let(:purl) do
      build(:purl, :was_seed, contents: [
              build(:resource, :image, files: [
                      build(:resource_file, :image, druid:)
                    ])
            ], druid:)
    end

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
    let(:purl) do
      build(:purl, :model_3d, contents: [
              build(:resource, :file, files: [
                      build(:resource_file, :model_3d, :world_downloadable, druid:)
                    ])
            ], druid:)
    end

    it 'tracks views' do
      visit_iframe_response(druid)
      wait_for_view
      expect(StubMetricsApi.last_event).to match(view_with_properties('druid' => druid))
    end

    it 'tracks file downloads' do
      visit_iframe_response(druid)
      click_button '1 file available for download'
      click_link 'Download abc_123.glb'
      wait_for_download
      expect(StubMetricsApi.last_event).to match(
        download_with_properties(
          'druid' => druid,
          'file' => 'abc_123.glb'
        )
      )
    end
  end

  describe 'file viewer' do
    let(:druid) { 'bc123df4567' }
    let(:purl) do
      build(:purl, :file, contents: [
              build(:resource, :audio, files: [
                      build(:resource_file, :image, :world_downloadable, druid:),
                      build(:resource_file, :audio, :world_downloadable, druid:)
                    ])
            ], druid:)
    end

    it 'tracks views' do
      visit_iframe_response(druid)
      wait_for_view
      expect(StubMetricsApi.last_event).to match(view_with_properties('druid' => druid))
    end

    it 'tracks file downloads' do
      visit_iframe_response(druid)
      click_link 'Download audio.mp3'
      wait_for_download
      expect(StubMetricsApi.last_event).to match(
        download_with_properties(
          'druid' => druid,
          'file' => 'audio.mp3'
        )
      )
    end

    it 'tracks object downloads' do
      visit_iframe_response(druid)
      click_button 'Download all 2 files (152.01 MB)'
      wait_for_download
      expect(StubMetricsApi.last_event).to match(download_with_properties('druid' => druid))
    end
  end
end
