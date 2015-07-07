module Embed
  class Viewer
    class Geo < CommonViewer

      def initialize(*args)
        super
      end

      def body_html
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-body sul-embed-geo', 'style' => "max-height: #{body_height}px", 'data-sul-embed-theme' => "#{asset_url('geo.css')}") do
            doc.script { doc.text ";jQuery.getScript(\"#{asset_url('geo.js')}\");" }
          end
        end.to_html
      end      
      
      def self.supported_types
        [:geo]
      end
    end
  end
end

Embed.register_viewer(Embed::Viewer::Geo) if Embed.respond_to?(:register_viewer)
