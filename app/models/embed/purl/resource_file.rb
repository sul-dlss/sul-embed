# frozen_string_literal: true

module Embed
  class Purl
    class ResourceFile
      def initialize(attributes = {})
        self.attributes = attributes
        yield(self) if block_given?
      end

      def attributes=(hash)
        hash.each do |key, value|
          public_send("#{key}=", value)
        end
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
    end
  end
end
