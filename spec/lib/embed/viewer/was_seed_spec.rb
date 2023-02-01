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
    subject { was_seed_viewer.archived_timemap_url }

    context 'with a valid url' do
      before do
        stub_purl_response_and_request(was_seed_purl, request)
      end

      it { is_expected.to eq 'https://swap.stanford.edu/timemap/http://naca.central.cranfield.ac.uk/' }
    end

    context 'with invalid url' do
      let(:invalid) do
        <<~XML
          <publicObject id="druid:gb089bd2251" published="2015-07-15T11:49:04-07:00">
            <identityMetadata>
              <sourceId source="sul">ARCHIVEIT-2361-naca.central.cranfield.ac.uk/</sourceId>
              <objectId>druid:gb089bd2251</objectId>
              <objectCreator>DOR</objectCreator>
              <objectLabel>http://naca.central.cranfield.ac.uk/</objectLabel>
              <objectType>item</objectType>
              <otherId name="uuid">9b83e130-2b21-11e5-a344-0050569b52d5</otherId>
              <tag>Remediated By : 4.21.2</tag>
            </identityMetadata>
            <contentMetadata type="webarchive-seed" id="druid:gb089bd2251">
              <resource type="image" sequence="1">
                 <file mimetype="image/jp2" id="thumbnail.jp2" size="21862">
                    <imageData width="400" height="400" />
                 </file>
              </resource>
            </contentMetadata>
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:fedora="info:fedora/fedora-system:def/relations-external#" xmlns:fedora-model="info:fedora/fedora-system:def/model#" xmlns:hydra="http://projecthydra.org/ns/relations#">
            <rdf:Description rdf:about="info:fedora/druid:gb089bd2251">
               <fedora:isMemberOf rdf:resource="info:fedora/druid:mk656nf8485" />
               <fedora:isMemberOfCollection rdf:resource="info:fedora/druid:mk656nf8485" />
            </rdf:Description>
            </rdf:RDF>
            <mods xmlns="http://www.loc.gov/mods/v3">
              <location>
                <url displayLabel="Archived website">https://swap.stanford.edu/http://naca.central.cranfield.ac.uk/</url>
              </location>
            </mods>
            <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:srw_dc="info:srw/schema/1/dc-schema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
              <dc:identifier>https://swap.stanford.edu/*/http://naca.central.cranfield.ac.uk/</dc:identifier>
            </oai_dc:dc>
          </publicObject>
        XML
      end

      before do
        stub_purl_response_and_request(invalid, request)
      end

      it { is_expected.to be_nil }
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
