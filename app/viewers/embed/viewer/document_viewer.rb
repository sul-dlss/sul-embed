# frozen_string_literal: true

module Embed
  module Viewer
    class DocumentViewer < CommonViewer
      def component
        PdfComponent
      end

      def importmap
        'document'
      end

      def stylesheet
        'document.css'
      end

      def self.show_download?
        true
      end

      def fullscreen?
        true
      end
    end
  end
end
