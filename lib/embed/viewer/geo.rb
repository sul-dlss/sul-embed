module Embed
  class Viewer
    class Geo
      include Embed::Viewer::CommonViewer

      def initialize(*args)
        super
      end

      def body_html
        return  "<div> I'm geo </div>"
      end
      
      def self.supported_types
        [:geo]
      end
    end
  end
end

Embed.register_viewer(Embed::Viewer::Geo) if Embed.respond_to?(:register_viewer)
