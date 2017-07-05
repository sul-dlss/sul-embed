require 'embed/viewer/uv_image'

module Embed
  class Viewer
    class UVFile < UVImage

      def self.supported_types
        [:'3d', :document]
      end

      private

      def manifest_json_url
        "#{Settings.purl_url}/#{@purl_object.druid}/iiif3/manifest.json"
      end
    end
  end
end

Embed.register_viewer(Embed::Viewer::UVFile) if Embed.respond_to?(:register_viewer)
