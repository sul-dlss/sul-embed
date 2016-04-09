require 'embed/media_tag'
module Embed
  class Viewer
    class Media < CommonViewer
      def body_html
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(
            class: 'sul-embed-body sul-embed-media',
            'style' => "max-height: #{body_height}px",
            'data-sul-embed-theme' => asset_url('media.css').to_s
          ) do
            Embed::MediaTag.new(doc, self)
            doc.script { doc.text ";jQuery.getScript(\"#{asset_url('media.js')}\");" }
          end
        end.to_html
      end

      def download_html
        return '' if @request.hide_download?
        Embed::DownloadPanel.new do
          Nokogiri::HTML::Builder.new do |doc|
            doc.div(class: 'sul-embed-panel-body') do
              @purl_object.contents.each do |resource|
                doc.ul(class: 'sul-embed-download-list') do
                  resource.files.each do |file|
                    doc.li(class: ('sul-embed-stanford-only' if file.stanford_only?).to_s) do
                      doc.a(href: file_url(file.title), title: file.title) do
                        doc.text "Download #{file.title}"
                      end
                    end
                  end
                end
              end
            end
          end.to_html
        end.to_html
      end

      def self.supported_types
        return [] unless ::Settings.enable_media_viewer?
        [:media]
      end

      def self.show_download?
        true
      end

      private

      def default_body_height
        400 - (header_height + footer_height)
      end
    end
  end
end

Embed.register_viewer(Embed::Viewer::Media) if Embed.respond_to?(:register_viewer)
