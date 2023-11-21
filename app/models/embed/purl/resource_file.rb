# frozen_string_literal: true

module Embed
  class Purl
    class ResourceFile
      NON_DOWNLOADABLE_ROLES = %w[thumbnail].freeze
      # Hardcoding some language code to label mappings, based on the mappings we currently need.
      # This approach should be revisited once we have more robust BCP 47 code to label mapping integrated.
      FILE_LANGUAGE_CAPTION_LABELS = {
        'en' => 'English',
        'ru' => 'Russian',
        'de' => 'German',
        'et' => 'Estonian',
        'lv' => 'Latvian',
        'es' => 'Spanish'
      }.freeze

      def initialize(attributes = {})
        self.attributes = attributes
        yield(self) if block_given?
      end

      def attributes=(hash)
        hash.each do |key, value|
          public_send("#{key}=", value)
        end
      end

      attr_accessor :druid, :label, :filename, :mimetype, :size, :duration, :language, :role,
                    :world_downloadable, :stanford_only, :location_restricted, :stanford_only_downloadable

      alias title filename
      alias world_downloadable? world_downloadable
      alias stanford_only? stanford_only
      alias location_restricted? location_restricted
      alias stanford_only_downloadable? stanford_only_downloadable

      ##
      # Creates a file url for stacks
      # @param [Boolean] download
      # @return [String]
      def file_url(download: false)
        # Allow literal slashes in the file URL (do not encode them)
        encoded_title = title.split('/').map { |title_part| ERB::Util.url_encode(title_part) }.join('/')
        uri = URI.parse("#{stacks_url}/#{encoded_title}")
        uri.query = URI.encode_www_form(download: true) if download
        uri.to_s
      end

      def stacks_url
        "#{Settings.stacks_url}/file/druid:#{@druid}"
      end

      def label_or_filename
        return caption_label if caption?

        label.presence || filename
      end

      def language_label
        FILE_LANGUAGE_CAPTION_LABELS.fetch(language_code, 'Unknown')
      end

      def caption_label
        "#{language_label} captions"
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

      def pdf?
        mimetype == 'application/pdf'
      end

      def image?
        mimetype =~ %r{image/jp2}i
      end
    end
  end
end
