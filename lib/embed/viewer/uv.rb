module Embed
  class Viewer
    class UV < CommonViewer

      def body_html
        "<p>#{@purl_object.type}</p>"
      end

      def self.supported_types
        [:image, :manuscript, :map, :book]
      end
    end
  end
end

Embed.register_viewer(Embed::Viewer::UV) if Embed.respond_to?(:register_viewer)
