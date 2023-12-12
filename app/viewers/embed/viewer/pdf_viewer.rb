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

      def available?
        restriction_message.blank?
      end

      def restriction_message
        # NOTE: that Stanford only restrictions are handled via a separate authorization flow,
        # since it is possible for Stanford people to do something about this restriction
        @restriction_message ||= if purl_object.embargoed? # check first, as it supercedes other restrictions
                                   # (NOTE: embargoed content is also citation only)
                                   "This content is embargoed until #{purl_object.embargo_release_date}."
                                 elsif purl_object.citation_only?
                                   'This content cannot be accessed online.'
                                 elsif purl_object.stanford_only_no_download?
                                   'This content cannot be accessed online. See access conditions for more information.'
                                 end
      end

      private

      def document_resource_files
        purl_object.contents.select { |content| content.type == 'document' }.map(&:files).flatten
      end
    end
  end
end
