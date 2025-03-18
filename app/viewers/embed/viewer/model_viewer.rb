# frozen_string_literal: true

module Embed
  module Viewer
    class ModelViewer < CommonViewer
      def component
        ModelComponent
      end

      def importmap
        'model'
      end

      def stylesheet
        'model'
      end

      def three_dimensional_files
        # we need downloadable files for the model viewer to render
        purl_object.contents.select(&:three_dimensional?).map(&:files).flatten.reject(&:no_download?).map do |file|
          file.file_url(download: false, version: purl_object.version_id)
        end
      end

      def fullscreen?
        true
      end

      def self.show_download?
        true
      end
    end
  end
end
