module Embed
  module Viewer
    class Media < CommonViewer
      def to_partial_path
        'embed/template/media'
      end

      def self.supported_types
        return [] unless ::Settings.enable_media_viewer?
        [:media]
      end

      # override CommonViewer instance method to ensure we do not show download panel when no downloadable files
      def show_download?
        super && @purl_object.downloadable_files.present?
      end

      def self.show_download?
        true
      end

      private

      def default_body_height
        400 - (header_height + footer_height)
      end
    end
  end
end
