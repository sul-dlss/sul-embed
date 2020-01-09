# frozen_string_literal: true

module Embed
  module Viewer
    class UVFile < UVImage
      def self.supported_types
        types = []
        types << :'3d' unless Settings.use_custom_3d_viewer
        types << :document unless Settings.use_custom_pdf_viewer
        types
      end

      def manifest_json_url
        "#{Settings.purl_url}/#{@purl_object.druid}/iiif3/manifest"
      end
    end
  end
end
