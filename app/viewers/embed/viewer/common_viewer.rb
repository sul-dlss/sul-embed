# frozen_string_literal: true

module Embed
  module Viewer
    class CommonViewer
      include Embed::Mimetypes
      include Embed::PrettyFilesize
      include Embed::StacksImage

      attr_reader :purl_object, :embed_request, :authorization

      delegate :any_stanford_only_files?, to: :authorization

      def initialize(embed_request)
        @embed_request = embed_request
        @purl_object = embed_request.purl_object
        @authorization = Authorization.new(@purl_object)
      end

      def height
        embed_request.maxheight || default_height
      end

      def width
        embed_request.maxwidth || default_width
      end

      def external_url
        nil
      end

      # indicates if viewer should display the Download All link in footer (override in specific viewer classes)
      def display_download_all?
        false
      end

      # link that will download all of the files in this object
      def download_url
        if @purl_object.version_id
          return "#{Settings.stacks_url}/object/#{@purl_object.druid}/version/#{@purl_object.version_id}"
        end

        "#{Settings.stacks_url}/object/#{@purl_object.druid}"
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
      # Should the download toolbar be shown?
      # @return [Boolean]
      def show_download?
        self.class.show_download? && !embed_request.hide_download?
      end

      def self.show_download?
        false
      end

      def fullscreen?
        false
      end

      def importmap
        nil
      end

      def file_type_icon(mimetype)
        Constants::FILE_ICON.fetch(mimetype, Icons::InsertDriveFileComponent)
      end

      ##
      # Not a great method name here as sometimes the header is still displayed,
      # even if the title is hidden.
      def display_header?
        !embed_request.hide_title?
      end

      def i18n_path
        "viewers.#{self.class.name.demodulize.underscore}"
      end

      def iframe_title
        I18n.t('title', default: 'Viewer', scope: i18n_path, title: purl_object.title)
      end

      private

      def default_width
        '100%'
      end

      def default_height
        '500px'
      end
    end
  end
end
