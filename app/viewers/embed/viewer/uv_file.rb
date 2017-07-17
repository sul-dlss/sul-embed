module Embed
  module Viewer
    class UVFile < UVImage
      def self.supported_types
        [:'3d', :document]
      end

      def manifest_json_url
        "#{Settings.purl_url}/#{@purl_object.druid}/iiif3/manifest.json"
      end
    end
  end
end
