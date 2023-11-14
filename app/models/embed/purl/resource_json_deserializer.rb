# frozen_string_literal: true

module Embed
  class Purl
    class ResourceJsonDeserializer
      LEGACY_TYPE_MAP = {
        'object' => 'file'
      }.freeze
      # @param [String] druid the identifier of the object
      # @param [Hash] json Cocina FileSet data
      def initialize(druid, json)
        @druid = druid
        @json = json
      end

      def deserialize
        description = @json['label']
        cocina_type = @json['type'].delete_prefix('https://cocina.sul.stanford.edu/models/resources/')
        Resource.new(
          druid: @druid,
          type: LEGACY_TYPE_MAP.fetch(cocina_type, cocina_type),
          description:,
          files: build_files(description)
        )
      end

      def build_files(description)
        @json.dig('structural', 'contains').map do |file|
          FileJsonDeserializer.new(@druid, description, file).deserialize
        end
      end
    end
  end
end
