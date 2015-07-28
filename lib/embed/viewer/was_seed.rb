module Embed
  class Viewer
    class WasSeed < CommonViewer

      def initialize(*args)
        super
      end

      def body_html
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-body sul-embed-was-seed', 'data-sul-embed-theme' => "#{asset_url('was_seed.css')}") do
            doc.div(id: 'sul-embed-was-seed') {}
            doc.script { doc.text ";jQuery.getScript(\"#{asset_url('was_seed.js')}\");" }
          end
        end.to_html
      end
      
      def self.supported_types
        [:"webarchive-seed"]
      end
      
    end
  end
end

Embed.register_viewer(Embed::Viewer::WasSeed) if Embed.respond_to?(:register_viewer)
