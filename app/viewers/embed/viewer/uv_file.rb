# frozen_string_literal: true

module Embed
  module Viewer
    class UVFile < UVImage
      def self.supported_types
        return %i[3d] if Settings.use_custom_pdf_viewer

        %i[3d document]
      end

      def manifest_json_url
        "#{Settings.purl_url}/#{@purl_object.druid}/iiif3/manifest"
      end
    end
  end
end
