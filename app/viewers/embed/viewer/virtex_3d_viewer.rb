# frozen_string_literal: true

module Embed
  module Viewer
    class Virtex3dViewer < CommonViewer
      def component
        Virtex3dComponent
      end

      def stylesheet
        'virtex_3d.css'
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
