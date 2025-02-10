# frozen_string_literal: true

module Embed
  class Purl
    class ResourceFile
      NON_DOWNLOADABLE_ROLES = %w[thumbnail].freeze

      def initialize(attributes = {})
        self.attributes = attributes
      end

      def attributes=(hash)
        hash.each do |key, value|
          public_send(:"#{key}=", value)
        end
      end

      attr_accessor :druid, :label, :filename, :mimetype, :size, :language, :role, :sdr_generated,
                    :world_downloadable, :stanford_only, :location_restricted, :stanford_only_downloadable

      alias title filename
      alias world_downloadable? world_downloadable
      alias stanford_only? stanford_only
      alias location_restricted? location_restricted
      alias stanford_only_downloadable? stanford_only_downloadable
      alias sdr_generated? sdr_generated

      ##
      # Creates a file url for stacks
      # @param [Boolean] download
      # @return [String]
      def file_url(download: false, version: nil)
        # Allow literal slashes in the file URL (do not encode them)
        encoded_title = title.split('/').map { |title_part| ERB::Util.url_encode(title_part) }.join('/')

        uri = if version
                URI.parse("#{versioned_stacks_url}/version/#{version}/#{encoded_title}")
              else
                URI.parse("#{stacks_url}/#{encoded_title}")
              end
        uri.query = URI.encode_www_form(download: true) if download
        uri.to_s
      end

      def stacks_url
        "#{Settings.stacks_url}/file/druid:#{@druid}"
      end

      def versioned_stacks_url
        "#{Settings.stacks_url}/v2/file/#{@druid}"
      end

      def label_or_filename
        return text_representation_label if caption? || transcript?

        label.presence || filename
      end

      def language_label
        Bcp47::Registry.resolve(language_code) || 'Unknown'
      end

      def media_caption_label
        "#{language_label}#{sdr_generated_text}"
      end

      def text_representation_label
        file_type = caption? ? 'captions' : 'transcript'
        "#{language_label} #{file_type}#{sdr_generated_text}"
      end

      def sdr_generated_text
        sdr_generated? ? ' (auto-generated)' : ''
      end

      def downloadable?
        (world_downloadable? || stanford_only_downloadable?) &&
          NON_DOWNLOADABLE_ROLES.exclude?(role)
      end

      def language_code
        language.presence || 'en'
      end

      def hierarchical_title
        title.split('/').last
      end

      def caption?
        role == 'caption'
      end

      def transcript?
        role == 'transcription'
      end

      def pdf?
        mimetype == 'application/pdf'
      end

      def image?
        mimetype =~ %r{image/jp2}i
      end
    end
  end
end
