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

      # At the purl object level, check if there are restrictions
      def location_restricted?
        purl_object.location_restriction
      end

      # Return the location for the restriction at the purl object level
      # Individual files may have different restrictons associated
      def restricted_location
        purl_object.restricted_location
      end

      # this indicates if the PDF is downloadable (though it could be stanford only)
      # Stanford only and location restrictions are handled via a separate authorization flow,
      # since it is possible for people to do something about the restriction
      def available?
        document_resource_files.first&.downloadable? || location_restricted?
      end

      private

      def document_resource_files
        purl_object.contents.select { |content| content.type == 'document' }.map(&:files).flatten
      end
    end
  end
end
