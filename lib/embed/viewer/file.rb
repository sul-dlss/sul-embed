module Embed
  class Viewer
    class File
      include Embed::Viewer::CommonViewer

      def self.default_viewer?
        true
      end

      def height
        '300'
      end

      def width
        '300'
      end

      def body_html
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-file') do
            doc.div(class: 'sul-embed-file-list') do
              doc.table do
                @purl_object.all_resource_files.each do |file|
                  doc.tr do
                    doc.td { doc.text file.mimetype }
                    doc.td { doc.text file.title }
                    doc.td { doc.text file.size }
                  end
                end
              end
            end
            doc.script { doc.text ";jQuery.getScript(\"#{asset_path('file.js')}\");" }
          end
        end.to_html
      end

      def self.supported_types
        [:media]
      end
    end
  end
end

Embed.register_viewer(Embed::Viewer::File) if Embed.respond_to?(:register_viewer)
