module Embed
  class Viewer
    class ImageX < CommonViewer

      def initialize(*args)
        super
      end

      def body_html
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-body sul-embed-image-x', 'data-sul-embed-theme' => "#{asset_url('image_x.css')}") do
            doc.div(id: 'sul-embed-geo-map', 'data-manifest-url'=>manifest_json_url) {}
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
    end
  end
end

Embed.register_viewer(Embed::Viewer::ImageX) if Embed.respond_to?(:register_viewer)
