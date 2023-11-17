# frozen_string_literal: true

module Embed
  class Purl
    class ResourceXmlDeserializer
      # @param [String] druid the identifier of the resource
      # @param [Nokogiri::XML::Element] resource
      # @param [Dor::RightsAuth] rights
      def initialize(druid, resource, rights)
        @druid = druid
        @resource = resource
        @rights = rights
      end

      def deserialize
        description = @resource.xpath('./label').text
        Resource.new(
          druid: @druid,
          type: @resource.attributes['type'].value,
          description:,
          files: build_files(description)
        )
      end

      def build_files(description)
        @resource.xpath('./file').map do |file|
          FileXmlDeserializer.new(@druid, description, file, @rights).deserialize
        end
      end
    end
  end
end
