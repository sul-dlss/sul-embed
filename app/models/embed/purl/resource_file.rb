# frozen_string_literal: true

module Embed
  class Purl
    class ResourceFile
      # @param [String] druid the identifier of the resource this file belongs to.
      # @param [String] description the label for this file
      # @param [Nokogiri::XML::Element] file
      # @param [Dor::RightsAuth] rights
      def initialize(druid, description, file, rights)
        @druid = druid
        @description = description
        @file = file
        @rights = rights
        @index = nil
      end

      attr_accessor :index

      def label
        @description
      end

      def title
        @file.attributes['id'].try(:value)
      end

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

      def hierarchical_title
        title.split('/').last
      end

      def vtt?
        mimetype == 'text/vtt'
      end

      def pdf?
        mimetype == 'application/pdf'
      end

      def mimetype
        @file.attributes['mimetype'].try(:value)
      end

      def image?
        mimetype =~ %r{image/jp2}i
      end

      # @return [Integer]
      def size
        @file.attributes['size']&.value.to_i
      end

      def duration
        md = Embed::MediaDuration.new(@file.xpath('./*[@duration]').first) if @file.xpath('./*/@duration').present?
        md&.to_s
      end

      def stanford_only?
        value, _rule = @rights.stanford_only_rights_for_file(title)

        value
      end

      def location_restricted?
        @rights.restricted_by_location?(title)
      end

      def world_downloadable?
        @rights.world_downloadable_file?(@file.attributes['id'])
      end
    end
  end
end
