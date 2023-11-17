# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Purl::ResourceXmlDeserializer do
  describe '#deserialize' do
    let(:resource_element) do
      Nokogiri::XML(
        <<~XML
          <resource sequence="1" type="image">
            <label>What a great image</label>
            <file id="Non thumb" mimetype="image/tiff" size="2799535" />
            <file id="The Thumb" mimetype="image/jp2" size="2799535" />
          </resource>
        XML
      ).xpath('//resource').first
    end

    let(:resource) { described_class.new('abc123', resource_element, nil).deserialize }

    it 'creates a resource' do
      expect(resource.druid).to eq 'abc123'
      expect(resource.description).to eq 'What a great image'
      expect(resource.type).to eq 'image'
      expect(resource.files).to all(be_a Embed::Purl::ResourceFile)
    end
  end
end
