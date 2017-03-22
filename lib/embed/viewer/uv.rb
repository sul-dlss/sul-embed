module Embed
  class Viewer
    class UV < CommonViewer

      def body_html
          <<-HTML.strip_heredoc
          <div class='sul-embed-body' style='height: #{body_height}px' data-sul-embed-theme='#{asset_url("uv.css")}'>
            <div class='uv' data-uri=''></div>
            <script id="embedUV" src='#{asset_url("uv.js")}'></script>
          </div>
          HTML
      end

      def self.supported_types
        [:image, :manuscript, :map, :book]
      end
    end
  end
end

Embed.register_viewer(Embed::Viewer::UV) if Embed.respond_to?(:register_viewer)
