# frozen_string_literal: true

module Embed
  module Viewer
    class UVImage < CommonViewer
      def to_partial_path
        'embed/template/uv_image'
      end

      def self.supported_types
        %i[image manuscript map book]
      end

      # we want to change this
      def config_url
        './uv-config.json'
      end

      def embed_url
        ".#{uv_root}/uv.js"
      end

      def uv_root
        "/uv-3-#{asset_thumbprint}"
      end

      # retrieve the MD5-thumbprinted name for our assets (see the rake uv:update task)
      def asset_thumbprint
        ::File.read(Rails.root.join('public/uv-3/.md5')).strip
      end

      def manifest_json_url
        @purl_object.manifest_json_url
      end

      def manifest_json
        @manifest_json ||= JSON.parse(@purl_object.manifest_json_response)
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

      def canvas_index
        if request.canvas_id
          canvases = manifest_json.fetch('sequences', []).map { |seq| seq['canvases'] }.first
          canvases.index { |canvas| canvas['@id'] == request.canvas_id } || request.canvas_index
        else
          request.canvas_index
        end
      end
    end
  end
end
