# frozen_string_literal: true

require 'rails_helper'

describe Embed::Envelope do
  include PURLFixtures
  describe '#initialize' do
    let(:envelope_object) { Embed::Envelope.new('test') }
    it 'creates an Envelope object' do
      expect(envelope_object).to be_an Embed::Envelope
      expect(envelope_object.instance_variable_get(:@envelope)).to eq 'test'
    end
  end
  describe '#to_bounding_box' do
    let(:envelope) do
      Embed::Envelope.new(Nokogiri::XML(geo_purl_public)
        .at_xpath('//gml:Envelope', 'gml' => 'http://www.opengis.net/gml/3.2/'))
    end
    let(:no_envelope) { Embed::Envelope.new(nil) }
    it 'returns nil if @envelope is falsy' do
      expect(no_envelope.to_bounding_box).to be_nil
    end
    it 'returns a 2D array when @envelope is a gml envelope' do
      expect(envelope.to_bounding_box.length).to eq 2
      expect(envelope.to_bounding_box).to eq [['-1.478794', '29.572742'], ['4.234077', '35.000308']]
    end
  end
end
