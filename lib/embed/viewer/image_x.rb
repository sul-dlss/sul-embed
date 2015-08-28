module Embed
  class Viewer
    class ImageX < CommonViewer

      def initialize(*args)
        super
        header_tools_logic << :image_button_logic
      end

      def body_html
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-body sul-embed-image-x', 'data-sul-embed-theme' => "#{asset_url('image_x.css')}") do
            doc.div(id: 'sul-embed-image-x', 'data-manifest-url'=>manifest_json_url, 'data-world-restriction' => !@purl_object.world_unrestricted?) {}
            doc.script { doc.text ";jQuery.getScript(\"#{asset_url('image_x.js')}\");" }
          end
        end.to_html
      end
      
      def self.supported_types
        [:image,:manuscript,:map,:book]
      end
      
      def manifest_json_url
        "#{Settings.purl_url}/#{@purl_object.druid}/iiif/manifest.json"
      end

      private

      def image_button_logic
        :image_button_html
      end

      def image_button_html(doc)
        doc.div(class: 'sul-embed-image-x-buttons') do
          doc.button(class: 'sul-embed-btn sul-embed-btn-xs sul-embed-btn-default sul-i-layout-none', 'data-sul-view-mode' => 'single')
          doc.button(class: 'sul-embed-btn sul-embed-btn-xs sul-embed-btn-default sul-i-layout-4', 'data-sul-view-mode' => 'book')
          doc.button(class: 'sul-embed-btn sul-embed-btn-xs sul-embed-btn-default sul-i-view-module-1', 'data-sul-view-perspective' => 'overview')
          doc.button(class: 'sul-embed-btn sul-embed-btn-xs sul-embed-btn-default sul-i-expand-1', 'data-sul-view-fullscreen' => 'fullscreen')
        end
      end
    end
  end
end

Embed.register_viewer(Embed::Viewer::ImageX) if Embed.respond_to?(:register_viewer)
