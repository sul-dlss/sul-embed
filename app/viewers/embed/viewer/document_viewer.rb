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

      # The PDFs the viewer can display, in the order they appear in the content list.
      #
      # @return [Array<Embed::Purl::ResourceFile>]
      def pdf_files
        @pdf_files ||= purl_object.resource_files.select(&:pdf?)
      end

      # The PDF the viewer opens on. Falls back to the first one when no filename was requested,
      # or when the requested one is not a PDF on this object.
      #
      # @return [Embed::Purl::ResourceFile, nil]
      def selected_file
        @selected_file ||= requested_file || pdf_files.first
      end

      # @return [String, nil] the URL identifying the selected PDF in the IIIF manifest
      def selected_file_url
        selected_file&.file_url
      end

      private

      def requested_file
        return if embed_request.filename.blank?

        pdf_files.find { |file| file.filename == embed_request.filename }
      end

      def page_from_canvas_index
        canvas_index = Integer(embed_request.canvas_index, exception: false)
        canvas_index + 1 if canvas_index && canvas_index >= 0
      end
    end
  end
end
