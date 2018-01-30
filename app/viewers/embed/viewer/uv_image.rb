module Embed
  module Viewer
    class UVImage < CommonViewer
      def to_partial_path
        'embed/template/uv_image'
      end

      def self.supported_types
        [:image, :manuscript, :map, :book]
      end

      # we want to change this
      def config_url
        './uv-config.json'
      end

      def embed_url
        "#{uv_root}/uv.js"
      end

      def uv_root
        './uv-3'
      end

      def manifest_json_url
        "#{Settings.purl_url}/#{@purl_object.druid}/iiif/manifest"
      end

      ##
      # Sets the default body height
      def default_body_height
        420
      end

      # The UV UI provides its own header and footer integrated into the viewer height itself.
      def header_height
        0
      end

      def footer_height
        0
      end
    end
  end
end
