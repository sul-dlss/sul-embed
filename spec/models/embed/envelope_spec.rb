# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Envelope do
  include PurlFixtures
  describe '#initialize' do
    let(:envelope_object) { described_class.new('test') }

    it 'creates an Envelope object' do
      expect(envelope_object).to be_an described_class
      expect(envelope_object.instance_variable_get(:@envelope)).to eq 'test'
    end
  end

  describe '#to_bounding_box' do
    let(:ng_xml) do
      Nokogiri::XML(<<~XML
          <rdf:Description xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" rdf:about="http://purl.stanford.edu/cz128vq0535">
          <dc:format xmlns:dc="http://purl.org/dc/elements/1.1/">application/x-esri-shapefile; format=Shapefile</dc:format>
          <dc:type xmlns:dc="http://purl.org/dc/elements/1.1/">Dataset#Polygon</dc:type>
          <gml:boundedBy xmlns:gml="http://www.opengis.net/gml/3.2/">
            <gml:Envelope gml:srsName="EPSG:4326">
              <gml:lowerCorner>29.572742 -1.478794</gml:lowerCorner>
              <gml:upperCorner>35.000308 4.234077</gml:upperCorner>
            </gml:Envelope>
          </gml:boundedBy>
          <dc:coverage xmlns:dc="http://purl.org/dc/elements/1.1/" rdf:resource="http://sws.geonames.org/226074/about.rdf" dc:language="eng" dc:title="Uganda" />
        </rdf:Description>
      XML
                   )
    end
    let(:envelope) do
      described_class.new(ng_xml.at_xpath('//gml:Envelope', 'gml' => 'http://www.opengis.net/gml/3.2/'))
    end
    let(:no_envelope) { described_class.new(nil) }

    it 'returns nil if @envelope is falsy' do
      expect(no_envelope.to_bounding_box).to be_nil
    end

    it 'returns a 2D array when @envelope is a gml envelope' do
      expect(envelope.to_bounding_box.length).to eq 2
      expect(envelope.to_bounding_box).to eq [['-1.478794', '29.572742'], ['4.234077', '35.000308']]
    end
  end
end
