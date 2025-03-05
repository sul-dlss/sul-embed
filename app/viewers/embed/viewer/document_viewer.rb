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

      def pdf_files
        document_resource_files.map(&:file_url)
      end

      def self.show_download?
        true
      end

      def fullscreen?
        true
      end

      # This indicates if the first PDF is downloadable (though it could be stanford only)
      # as well as location restricted.  Authorization for other documents will be
      # checked as the user clicks on items in the content side bar.
      def available?
        !(document_resource_files.first&.no_download?)
      end

      private

      def document_resource_files
        purl_object.contents.select { |content| content.type == 'document' }.map(&:files).flatten
      end
    end
  end
end
