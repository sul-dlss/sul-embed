# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Viewer::WasSeed do
  include PurlFixtures
  include WasTimeMapFixtures
  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:was_seed_viewer) { described_class.new(request) }
  let(:purl) { "#{Settings.purl_url}/abc123" }

  describe 'initialize' do
    it 'is an Embed::Viewer::WasSeed' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(was_seed_viewer).to be_an described_class
    end
  end

  describe 'self.supported_types' do
    it 'returns an array of supported types' do
      expect(described_class.supported_types).to eq [:'webarchive-seed']
    end
  end

  describe '#archived_site_url' do
    it 'parses a mods archived site' do
      stub_purl_response_and_request(was_seed_purl, request)
      expect(was_seed_viewer.archived_site_url).to eq 'https://swap.stanford.edu/*/http://naca.central.cranfield.ac.uk/'
    end
  end

  describe '#archived_timemap_url' do
    it 'parses a mods archived site' do
      stub_purl_response_and_request(was_seed_purl, request)
      expect(was_seed_viewer.archived_timemap_url).to eq 'https://swap.stanford.edu/timemap/http://naca.central.cranfield.ac.uk/'
    end
  end

  describe '#shelved_thumb' do
    it 'parses a mods archived site' do
      stub_purl_response_and_request(was_seed_purl, request)
      expect(was_seed_viewer.shelved_thumb).to eq 'https://stacks.stanford.edu/image/iiif/12345%2Fthumbnail/full/200,/0/default.jpg'
    end
  end

  describe 'format_memento_datetime' do
    it 'returns a formated memento datetime' do
      stub_request(request)
      expect(was_seed_viewer.format_memento_datetime('20121129060351')).to eq('29 November 2012')
    end
  end

  describe 'default_height' do
    it 'defaults to 353' do
      stub_request(request)

      expect(was_seed_viewer.send(:default_height)).to eq 420
    end

    it 'is smaller when the title is hidden' do
      expect(request).to receive(:hide_title?).and_return(true)
      stub_request(request)

      expect(was_seed_viewer.send(:default_height)).to eq 340
    end
  end

  describe '.external_url' do
    it 'builds the external url based on wayback url as extracted from prul' do
      stub_purl_response_and_request(was_seed_purl, request)
      expect(was_seed_viewer.external_url).to eq('https://swap.stanford.edu/*/http://naca.central.cranfield.ac.uk/')
    end
  end
end
