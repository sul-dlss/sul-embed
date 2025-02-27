# frozen_string_literal: true

module Embed
  module Viewer
    class ModelViewer < CommonViewer
      def component
        new_viewer? ? ModelComponent : ::Legacy::ModelComponent
      end

      def importmap
        new_viewer? ? 'model' :  'legacy_3d'
      end

      def stylesheet
        new_viewer? ? 'model' :  'legacy_model.css'
      end

      def three_dimensional_files
        # we need downloadable files for the model viewer to render
        purl_object.contents
                   .select(&:three_dimensional?)
                   .map(&:files).flatten
                   .reject(&:no_download?)
                   .map(&:file_url)
      end

      def fullscreen?
        true
      end

      def self.show_download?
        true
      end

      private

      def default_height
        new_viewer? ? super : '513px'
      end
    end
  end
end
