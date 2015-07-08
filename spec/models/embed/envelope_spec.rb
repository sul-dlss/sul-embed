require "rails_helper"

describe Embed::Envelope do
  include PURLFixtures
  describe 'to_bounding_box' do
    it 'should extract a simple array from the xml' do
      stub_purl_response_with_fixture(geo_purl)
      @envelope_ng = Embed::PURL.new('1234').ng_xml.xpath('//gml:Envelope', 'gml'=>'http://www.opengis.net/gml/3.2/').first
      expect(Embed::Envelope.new(@envelope_ng).to_bounding_box()).to eq [["38.298673","-123.387626"],[ "39.399103", "-122.528843"]] 
    end
    it 'should return nil if there is no envelope present' do
      stub_purl_response_with_fixture(image_purl)
      @envelope_nil = Embed::PURL.new('1234').ng_xml.xpath('//gml:Envelope', 'gml'=>'http://www.opengis.net/gml/3.2/').first
      expect(Embed::Envelope.new(@envelope_nil).to_bounding_box()).to eq nil 
    end
  end
  describe 'lower_corner' do
    before do
      stub_purl_response_with_fixture(geo_purl)
      @envelope_ng = Embed::PURL.new('1234').ng_xml.xpath('//gml:Envelope', 'gml'=>'http://www.opengis.net/gml/3.2/').first
    end
    it 'should give the lower_corner value as array of 2 strings' do
      expect(Embed::Envelope.new(@envelope_ng).send(:lower_corner)).to eq ["-123.387626", "38.298673"] 
    end
  end
  describe 'should give the upper_corner value as array of 2 strings' do
    before do
      stub_purl_response_with_fixture(geo_purl)
      @envelope_ng = Embed::PURL.new('1234').ng_xml.xpath('//gml:Envelope', 'gml'=>'http://www.opengis.net/gml/3.2/').first
    end
    it 'should extract a simple array from the xml' do
      expect(Embed::Envelope.new(@envelope_ng).send(:upper_corner)).to eq ["-122.528843", "39.399103"] 
    end
  end
end
