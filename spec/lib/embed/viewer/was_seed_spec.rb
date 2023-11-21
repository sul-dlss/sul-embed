# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Viewer::WasSeed do
  include PurlFixtures
  include WasTimeMapFixtures
  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:was_seed_viewer) { described_class.new(request) }
  let(:purl) { build(:purl, :was_seed) }

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
  end

  describe 'initialize' do
    it 'is an Embed::Viewer::WasSeed' do
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
      expect(was_seed_viewer.archived_site_url).to eq 'https://swap.stanford.edu/*/http://naca.central.cranfield.ac.uk/'
    end
  end

  describe '#archived_timemap_url' do
    subject { was_seed_viewer.archived_timemap_url }

    context 'with a valid url' do
      it { is_expected.to eq 'https://swap.stanford.edu/timemap/http://naca.central.cranfield.ac.uk/' }
    end

    context 'with invalid url' do
      let(:purl) { build(:purl, :was_seed, archived_site_url: 'https://swap.stanford.edu/http://naca.central.cranfield.ac.uk/') }

      it { is_expected.to be_nil }
    end
  end

  describe '#shelved_thumb' do
    it 'parses a mods archived site' do
      expect(was_seed_viewer.shelved_thumb).to eq 'https://stacks.stanford.edu/image/iiif/abc123%2Fimage_001/full/200,/0/default.jpg'
    end
  end

  describe 'format_memento_datetime' do
    it 'returns a formated memento datetime' do
      expect(was_seed_viewer.format_memento_datetime('20121129060351')).to eq('29 November 2012')
    end
  end

  describe 'default_height' do
    it 'defaults to 353' do
      expect(was_seed_viewer.send(:default_height)).to eq 420
    end

    it 'is smaller when the title is hidden' do
      expect(request).to receive(:hide_title?).and_return(true)
      expect(was_seed_viewer.send(:default_height)).to eq 340
    end
  end

  describe '.external_url' do
    it 'builds the external url based on wayback url as extracted from prul' do
      expect(was_seed_viewer.external_url).to eq('https://swap.stanford.edu/*/http://naca.central.cranfield.ac.uk/')
    end
  end
end
