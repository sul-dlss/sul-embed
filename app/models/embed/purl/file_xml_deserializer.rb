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

      def filename
        @filename ||= @file.attributes['id'].value
      end

      def stanford_only
        @rights.stanford_only_rights_for_file(filename).first
      end

      def location_restricted
        @rights.restricted_by_location?(filename)
      end

      def world_downloadable
        @rights.world_downloadable_file?(filename)
      end

      def stanford_only_downloadable
        @rights.stanford_only_downloadable_file?(filename)
      end

      def duration
        return if @file.xpath('./*/@duration').blank?

        Embed::MediaDuration.new(@file.xpath('./*[@duration]').first).to_s
      end

      # rubocop:disable Metrics/AbcSize
      def deserialize
        ResourceFile.new(
          druid: @druid,
          label: @description,
          mimetype: @file.attributes['mimetype']&.value,
          size: @file.attributes['size']&.value.to_i,
          role: @file.attributes['role']&.value,
          language: @file.attributes['language']&.value,
          filename:,
          stanford_only:,
          location_restricted:,
          world_downloadable:,
          stanford_only_downloadable:
        ) do |file|
          file.duration = duration
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
