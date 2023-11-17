# frozen_string_literal: true

module Embed
  class Purl
    class FileXmlDeserializer
      # @param [String] druid the identifier of the resource this file belongs to.
      # @param [String] description the label for this file
      # @param [Nokogiri::XML::Element] file
      # @param [Dor::RightsAuth] rights
      def initialize(druid, description, file, rights)
        @druid = druid
        @description = description
        @file = file
        @rights = rights
      end

      def deserialize
        ResourceFile.new(
          druid: @druid,
          label: @description,
          filename: @file.attributes['id'].value,
          mimetype: @file.attributes['mimetype']&.value,
          size: @file.attributes['size']&.value.to_i,
          rights: @rights
        ) do |file|
          if @file.xpath('./*/@duration').present?
            file.duration = Embed::MediaDuration.new(@file.xpath('./*[@duration]').first).to_s
          end
        end
      end
    end
  end
end
