# frozen_string_literal: true

module Embed
  module Viewer
    class CommonViewer
      include Embed::Mimetypes
      include Embed::PrettyFilesize
      include Embed::StacksImage

      attr_reader :purl_object, :request

      def initialize(request)
        @request = request
        @purl_object = request.purl_object
      end

      def stacks_url
        "#{Settings.stacks_url}/file/druid:#{@purl_object.druid}"
      end

      def height
        @request.maxheight || default_height
      end

      def width
        @request.maxwidth || default_width
      end

      def external_url
        nil
      end

      ##
      # Creates a file url for stacks
      # @param [String] title
      # @param [Boolean] download
      # @param [Boolean] allow_literal_slashes
      # @return [String]
      def file_url(title, download: false, allow_literal_slashes: false)
        title_parts = allow_literal_slashes ? title.split('/') : [title]
        encoded_title = title_parts.map { |title_part| ERB::Util.url_encode(title_part) }.join('/')
        uri = URI.parse("#{stacks_url}/#{encoded_title}")
        uri.query = URI.encode_www_form(download: true) if download
        uri.to_s
      end

      ##
      # Checks to see if an item is embargoed to the world
      # @param [Embed::Purl::Resource::ResourceFile]
      # @return [Boolean]
      def embargoed_to_world?(file)
        @purl_object.embargoed? && !file.stanford_only?
      end

      ##
      # Creates a pretty date in a standardized sul way
      # @param [String] date_string
      # @return [String]
      def sul_pretty_date(date_string)
        I18n.l(Date.parse(date_string), format: :sul) if date_string.present?
      end

      ##
      # Should the download toolbar be shown?
      # @return [Boolean]
      def show_download?
        self.class.show_download? && !@request.hide_download?
      end

      # Should the download file count be shown (when download toolbar is shown)?
      def show_download_count?
        self.class.show_download_count?
      end

      def self.show_download?
        false
      end

      # default is to show the download file count (when download toolbar is shown)
      def self.show_download_count?
        true
      end

      def tooltip_text(file)
        return unless file.stanford_only?

        ['Available only to Stanford-affiliated patrons',
         sul_pretty_date(@purl_object.embargo_release_date)]
          .compact.join(' until ')
      end

      def fullscreen?
        false
      end

      ##
      # Not a great method name here as sometimes the header is still displayed,
      # even if the title is hidden.
      def display_header?
        !@request.hide_title?
      end

      def iframe_title
        I18n.t("viewers.#{self.class.name.demodulize.underscore}.title", default: 'Viewer')
      end

      private

      def default_height
        520
      end

      def default_width
        nil
      end
    end
  end
end
