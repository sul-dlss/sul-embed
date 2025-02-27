# frozen_string_literal: true

module Embed
  class Purl
    class FileJsonDeserializer
      # @param [String] druid the identifier of the resource this file belongs to.
      # @param [String] description the label for this file
      # @param [Hash] file cocina file data
      # @param [String] parent resource type, used for caption/transcript viewing
      def initialize(druid, description, file, resource_type)
        @druid = druid
        @description = description
        @file = file
        @resource_type = resource_type
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
        klass = case @resource_type
                when 'audio', 'video'
                  MediaFile
                else
                  ResourceFile
                end
        result = klass.new(
          druid: @druid,
          label: @description,
          mimetype: @file.fetch('hasMimeType'),
          size: @file.fetch('size'),
          role: @file['use'],
          filename:,
          stanford_only:,
          location_restricted:,
          world_downloadable:,
          stanford_only_downloadable:
        )

        if klass == MediaFile
          result.language = @file['languageTag']
          # Note that `sdr_generated' is not a media specific field in SDR, but in sul-embed, we only use it for media.
          result.sdr_generated = sdr_generated
        end

        result
      end
    end
  end
end
