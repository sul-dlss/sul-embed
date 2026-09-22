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

      # An explicit page wins over the canvas index, which predates it and says the same thing
      # in zero-based terms.
      def page
        super || page_from_canvas_index
      end

      private

      def page_from_canvas_index
        canvas_index = Integer(embed_request.canvas_index, exception: false)
        canvas_index + 1 if canvas_index && canvas_index >= 0
      end
    end
  end
end
