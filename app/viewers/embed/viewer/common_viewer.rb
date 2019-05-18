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

      def asset_url(file)
        "#{asset_host}#{ActionController::Base.helpers.asset_url(file)}"
      end

      def asset_host
        if Rails.env.production?
          Settings.static_assets_base
        else
          "//#{@request.rails_request.host_with_port}"
        end
      end

      def stacks_url
        "#{Settings.stacks_url}/file/druid:#{@purl_object.druid}"
      end

      def height
        @request.maxheight || calculate_height
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
      # @return [String]
      def file_url(title, download: false)
        uri = URI.parse("#{stacks_url}/#{ERB::Util.url_encode(title)}")
        uri.query = URI.encode_www_form(download: true) if download
        uri.to_s
      end

      ##
      # Checks to see if an item is embargoed to the world
      # @param [Embed::PURL::Resource::ResourceFile]
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

      # Set a specific height for the body. We need to subtract
      # the header and footer heights from the consumer
      # requested maxheight, otherwise we set a default
      # which can be set by the specific viewers.
      def body_height
        if @request.maxheight
          @request.maxheight.to_i - (header_height + footer_height)
        else
          default_body_height
        end
      end

      def self.show_download?
        false
      end

      # default is to show the download file count (when download toolbar is shown)
      def self.show_download_count?
        true
      end

      def container_styles
        return unless height_style.present? || width_style.present?

        [height_style, width_style].compact.join(' ').to_s
      end

      def tooltip_text(file)
        return unless file.stanford_only?

        ['Available only to Stanford-affiliated patrons',
         sul_pretty_date(@purl_object.embargo_release_date)]
          .compact.join(' until ')
      end

      ##
      # Not a great method name here as sometimes the header is still displayed,
      # even if the title is hidden.
      def display_header?
        !@request.hide_title?
      end

      private

      def height_style
        return 'max-height:100%;' if @request.fullheight?

        "max-height:#{height}px;" if height
      end

      def width_style
        "max-width:#{width_style_attribute};"
      end

      def width_style_attribute
        return '100%' unless width

        "#{width}px"
      end

      def header_height
        return 0 unless display_header?

        63
      end

      def footer_height
        30
      end

      def calculate_height
        return nil unless body_height

        body_height + header_height + footer_height
      end

      def default_width
        nil
      end

      def default_body_height
        nil
      end
    end
  end
end
