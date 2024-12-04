# frozen_string_literal: true

module Embed
  class Purl
    class FileJsonDeserializer
      # @param [String] druid the identifier of the resource this file belongs to.
      # @param [String] description the label for this file
      # @param [Hash] file cocina file data
      def initialize(druid, description, file)
        @druid = druid
        @description = description
        @file = file
      end

      def filename
        @filename ||= @file.fetch('filename')
      end

      def stanford_only
        view == 'stanford'
      end

      def location_restricted
        download == 'location-based'
      end

      def world_downloadable
        download == 'world'
      end

      def stanford_only_downloadable
        download == 'stanford'
      end

      def download
        @file.fetch('access').fetch('download')
      end

      def view
        @file.fetch('access').fetch('view')
      end

      def sdr_generated
        @file.fetch('sdrGeneratedText', false)
      end

      def deserialize # rubocop:disable Metrics/MethodLength
        ResourceFile.new(
          druid: @druid,
          label: @description,
          mimetype: @file.fetch('hasMimeType'),
          size: @file.fetch('size'),
          role: @file['use'],
          language: @file['languageTag'],
          filename:,
          stanford_only:,
          location_restricted:,
          world_downloadable:,
          sdr_generated:,
          stanford_only_downloadable:
        )
      end
    end
  end
end
