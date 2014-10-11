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
          doc.div(class: 'sul-embed-body sul-embed-file', 'data-sul-embed-theme' => "#{asset_url('file.css')}") do
            doc.div(class: 'sul-embed-file-list') do
              doc.ul(class: 'sul-embed-media-list') do
                @purl_object.contents.each do |resource|
                  doc.li(class: 'sul-embed-media') do
                    doc.div(class: 'sul-embed-count pull-left') do
                      doc.text resource.sequence
                    end
                    doc.div(class: 'sul-embed-media-object pull-left') do
                      doc.i(class: 'fa fa-file fa-3x')
                    end
                    doc.div(class: 'sul-embed-media-body') do
                      doc.div(class: 'sul-embed-media-heading') do
                        doc.a(href: file_url(resource.files.first.title)) do
                          doc.text resource.files.first.title
                        end
                      end
                      doc.div(class: 'sul-embed-description') do
                        doc.text resource.description
                      end
                      doc.div(class: 'sul-embed-download') do
                        doc.i(class: 'fa fa-download')
                        doc.a(href: file_url(resource.files.first.title), download: nil) do
                          doc.text pretty_filesize(resource.files.first.size)
                        end
                      end
                    end
                  end
                end
              end
            end
            doc.script { doc.text ";jQuery.getScript(\"#{asset_url('file.js')}\");" }
          end
        end.to_html
      end

      def pretty_filesize(size)
        Filesize.from("#{size} B").pretty
      end

      def file_url(title)
        "#{stacks_url}/#{title}"
      end

      def self.supported_types
        [:media]
      end
    end
  end
end

Embed.register_viewer(Embed::Viewer::File) if Embed.respond_to?(:register_viewer)
