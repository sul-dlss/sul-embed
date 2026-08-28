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

      def page
        canvas_index = Integer(embed_request.canvas_index, exception: false)
        canvas_index + 1 if canvas_index && canvas_index >= 0
      end
    end
  end
end
