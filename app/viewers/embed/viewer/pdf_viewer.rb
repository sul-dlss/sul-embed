# frozen_string_literal: true

module Embed
  module Viewer
    class PdfViewer < CommonViewer
      def component
        # Use the new object tag PDF compotent if feature flag provided
        return LegacyPdfComponent if Settings.enabled_features.legacy_pdf_viewer

        PdfComponent
      end

      def importmap
        'document' unless Settings.enabled_features.legacy_pdf_viewer
      end

      def stylesheet
        'pdf.css'
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

      def all_documents_location_restricted?
        document_resource_files.all?(&:location_restricted?)
      end

      private

      def document_resource_files
        purl_object.contents.select { |content| content.type == 'document' }.map(&:files).flatten
      end
    end
  end
end
