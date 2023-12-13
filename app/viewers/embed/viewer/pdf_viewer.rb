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

      # this indicates if the PDF is accessible (either to all or to stanford people)
      def available?
        purl_object.public? || purl_object.stanford_only_unrestricted?
      end

      def restriction_message
        # NOTE: Stanford only restrictions are handled via a separate authorization flow,
        # since it is possible for Stanford people to do something about the restriction
        @restriction_message ||= if purl_object.embargoed? # check first, as it supercedes other restrictions
                                   # NOTE: embargoed content is also citation only, so check first to show message
                                   I18n.t('restrictions.embargoed', date: formatted_embargo_release_date)
                                 # NOTE: PDFs with no download can't be viewed in a browser either, so no access
                                 elsif purl_object.citation_only? || no_download?
                                   I18n.t('restrictions.not_accessibile')
                                 end
      end

      private

      def formatted_embargo_release_date
        I18n.l(Date.parse(purl_object.embargo_release_date), format: :sul)
      end

      def document_resource_files
        purl_object.contents.select { |content| content.type == 'document' }.map(&:files).flatten
      end

      # first PDF file is set to no download
      def no_download?
        !document_resource_files.first&.downloadable?
      end
    end
  end
end
