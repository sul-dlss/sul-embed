# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Purl::FileXmlDeserializer do
  describe '#deserialize' do
    let(:file_node) do
      Nokogiri::XML(
        <<~XML
          <file size="12345" mimetype="image/jp2" id="myvideo.mp4"/>
        XML
      ).root
    end
    let(:rights) do
      instance_double(Dor::RightsAuth, stanford_only_rights_for_file: [false, nil],
                                       restricted_by_location?: false,
                                       world_downloadable_file?: true,
                                       stanford_only_downloadable_file?: false)
    end

    let(:resource_file) { described_class.new('abc123', 'desc', file_node, rights).deserialize }

    it 'creates a resource file' do
      expect(resource_file.druid).to eq 'abc123'
      expect(resource_file.label).to eq 'desc'
      expect(resource_file.mimetype).to eq 'image/jp2'
      expect(resource_file.size).to eq 12_345
      expect(resource_file.filename).to eq 'myvideo.mp4'
    end

    context 'when file size is empty' do
      let(:file_node) do
        Nokogiri::XML(
          <<~XML
            <file size="" mimetype="image/jp2" id="myvideo.mp4"/>
          XML
        ).root
      end

      it 'casts it to 0' do
        expect(resource_file.size).to eq 0
      end
    end
  end
end
