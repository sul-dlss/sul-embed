# frozen_string_literal: true

module Embed
  module Viewer
    class PDFViewer < CommonViewer
      def to_partial_path
        'embed/template/pdf_viewer'
      end

      def pdf_files
        document_resource_files.map(&:title).map do |filename|
          "#{stacks_url}/#{filename}"
        end
      end

      ##
      # Sets the default body height
      def default_body_height
        420
      end

      def self.supported_types
        %i[document]
      end

      private

      def document_resource_files
        purl_object.contents.select { |content| content.type == 'document' }.map(&:files).flatten
      end
    end
  end
end
