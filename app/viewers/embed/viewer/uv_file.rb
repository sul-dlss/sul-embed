# frozen_string_literal: true

module Embed
  module Viewer
    class UVFile < UVImage
      def self.supported_types
        %i[3d]
      end

      def manifest_json_url
        "#{Settings.purl_url}/#{@purl_object.druid}/iiif3/manifest"
      end
    end
  end
end
