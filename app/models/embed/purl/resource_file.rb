# frozen_string_literal: true

module Embed
  class Purl
    class ResourceFile
      FILE_LANGUAGE_CAPTION_LABELS = {
        'en' => 'English captions',
        'ru' => 'Russian captions'
      }.freeze

      def initialize(attributes = {})
        self.attributes = attributes
        yield(self) if block_given?
      end

      attr_accessor :druid, :label, :filename, :mimetype, :size, :duration,
                    :world_downloadable, :stanford_only, :location_restricted

      alias title filename
      alias world_downloadable? world_downloadable
      alias stanford_only? stanford_only
      alias location_restricted? location_restricted

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

      # def label
      #   return caption_label if caption?
      #   return resource.description if resource.description.present?
      #   title

      def label_or_filename
        label.presence || filename
      end

      def hierarchical_title
        title.split('/').last
      end

      def vtt?
        mimetype == 'text/vtt'
      end

      def pdf?
        mimetype == 'application/pdf'
      end

      def image?
        mimetype =~ %r{image/jp2}i
      end

      def caption?
        role == 'caption'
      end

      def role
        @file.attributes['role'].try(:value)
      end

      def caption_label
        return default_caption_label unless resource.multilingual_captions?

        FILE_LANGUAGE_CAPTION_LABELS.fetch(language, default_caption_label)
      end

      def default_caption_label
        'Caption file'
      end

      def language
        @file.attributes['language'].try(:value)
      end
    end
  end
end
