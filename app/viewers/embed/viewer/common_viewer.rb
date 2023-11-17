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

      def height
        @request.maxheight || default_height
      end

      def width
        @request.maxwidth || default_width
      end

      def external_url
        nil
      end

      def stylesheet
        "#{purl_object.type}.css"
      end

      ##
      # Checks to see if an item is embargoed to the world
      # @param [Embed::Purl::ResourceFile]
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

      def self.show_download?
        false
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
