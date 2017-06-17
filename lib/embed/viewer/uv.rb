module Embed
  class Viewer
    class UV < CommonViewer

      def body_html
          <<-HTML.strip_heredoc
          <script type='text/javascript' src='/uv-3/helpers.js'></script>
          <script type='text/javascript' src='/uv-3/lib/offline.js'></script>
          <div class='sul-embed-body' style='height: #{body_height}px' data-sul-embed-theme='#{asset_url("uv.css")}'>
            <div id='uv' class='uv' data-behavior='uv' data-uv-root='#{uv_root}' data-uv-uri='#{manifest_json_url}' data-uv-config='#{config_url}' style='height: #{body_height}px; width:100%'></div>
            <script>
              ;jQuery.getScript("#{asset_url('uv.js')}");
            </script>
            <script id='embedUV' src='#{embed_url}'></script>
          </div>
          HTML
      end

      def self.supported_types
        [:image, :manuscript, :map, :book]
      end

      private

      # we want to change this
      def config_url
        '/uv-config.json'
      end

      def embed_url
        "#{uv_root}/uv.js"
      end

      def uv_root
        '/uv-3'
      end

      def manifest_json_url
        "#{Settings.purl_url}/#{@purl_object.druid}/iiif/manifest.json"
      end

      def default_body_height
        420
      end

    end
  end
end

Embed.register_viewer(Embed::Viewer::UV) if Embed.respond_to?(:register_viewer)
