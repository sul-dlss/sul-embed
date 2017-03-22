module Embed
  class Viewer
    class UV < CommonViewer

      def body_html
          <<-HTML.strip_heredoc
          <div class='sul-embed-body' style='height: #{body_height}px' data-sul-embed-theme='#{asset_url("uv.css")}'>
            <div class='uv' data-uri='#{manifest_json_url}' data-locale="en-GB:English" data-config='#{config_url}' style='height: #{body_height}px; width:100%'></div>
            <script src='#{asset_url("uv.js")}'></script>
            #{::PulUvRails::UniversalViewer.script_tag}
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
