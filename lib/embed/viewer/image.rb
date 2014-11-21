module Embed
  class Viewer
    class Image
      include Embed::Viewer::CommonViewer

      def initialize(*args)
        super
        header_tools_logic
      end

      def body_html
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-body sul-embed-image', 'data-sul-embed-theme' => "#{asset_url('image.css')}", 'data-plugin-styles' => "#{asset_url('iiifOsdViewer.css')}") do
            doc.div(class: 'sul-embed-image-list') do
              height = body_height ? ('height: ' + body_height.to_s + 'px') : ""
              doc.div(class: 'sul-embed-iiif-osd', style: "#{height}", 'data-iiif-image-info' => "#{iiif_image_info(@purl_object.contents).to_json}", 'data-iiif-server' => "#{iiif_server()}")
            end
            doc.script { doc.text ";jQuery.getScript(\"#{asset_url('image.js')}\");" }
          end
        end.to_html
      end

      def download_html
        return '' if @request.hide_download?
        sizes = Constants::IMAGE_DOWNLOAD_SIZES

        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-panel-container') do
            doc.div(class: 'sul-embed-panel sul-embed-download-panel', style: 'display:none;', :'aria-hidden' => 'true') do
              doc.div(class: 'sul-embed-panel-header') do
                doc.button(class: 'sul-embed-close', 'data-toggle' => 'sul-embed-download-panel') do
                  doc.span('aria-hidden' => true, class: 'fa fa-close') {}
                  doc.span(class: 'sul-embed-sr-only') { doc.text "Close" }
                end
                doc.div(class: 'sul-embed-panel-title') do
                  doc.text "Download image"
                  doc.span(class: "sul-embed-panel-item-label")
                end
              end
              doc.table(class: 'sul-embed-download-options', :'data-download-sizes' => "#{sizes.to_json}", :'data-stacks-url' => "#{Settings.stacks_url}") do
                sizes.each do |size|
                  doc.tr do
                    doc.td(:class => "sul-embed-download-size-type sul-embed-download-#{size}") do
                      if (size != 'default')
                        doc.a(class: 'download-link', href: 'javascript:;') {
                          doc.text "#{size} ("
                          doc.span(class: "sul-embed-download-dimensions")
                          doc.text ")"
                        }
                        doc.span(class: "sul-embed-stanford-only", style: "display: none;") do
                          doc.a(href: 'javascript:;', title: '', 'data-sul-embed-tooltip' => false) {}
                        end
                      else
                        doc.span() {
                          doc.text "#{size} ("
                          doc.span(class: "sul-embed-download-dimensions")
                          doc.text ")"
                        }
                      end
                    end
                  end
                end
              end
            end
          end
        end.to_html
      end

      def image_id(image)
        ::File.basename(image.title, ::File.extname(image.title))
      end

      def iiif_image_id(image)
        @purl_object.druid + '%252F' + image_id(image)
      end

      def iiif_image_info(contents)
        data = []

        contents.each do |resource|
          resource.files.each do |image|
            if image.is_image?
              data.push({
                id: iiif_image_id(image),
                height: image.image_height,
                width: image.image_width,
                label: resource.description,
                stanford_only: image.stanford_only?,
                tooltip_text: tooltip_text(image)
              })
            end
          end
        end

        data
      end

      def iiif_server
        "#{Settings.iiif_stacks_url}/image/iiif"
      end

      def default_body_height
        500
      end

      def self.supported_types
        [:image, :manuscript, :map, :book]
      end
    end
  end
end

Embed.register_viewer(Embed::Viewer::Image) if Embed.respond_to?(:register_viewer)
