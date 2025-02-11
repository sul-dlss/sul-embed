# frozen_string_literal: true

module Embed
  module Viewer
    class ModelViewer < CommonViewer
      def component
        ::Legacy::ModelComponent
      end

      def importmap
        'legacy_3d'
      end

      def stylesheet
        'legacy_model.css'
      end

      def three_dimensional_files
        purl_object.contents.select(&:three_dimensional?).map(&:files).flatten.map(&:file_url)
      end

      def fullscreen?
        true
      end

      def self.show_download?
        true
      end

      private

      def default_height
        513
      end
    end
  end
end
