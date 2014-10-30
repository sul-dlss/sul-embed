module Embed
  class Viewer
    class Image
      include Embed::Viewer::CommonViewer

      def body_html
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-body sul-embed-file', 'data-sul-embed-theme' => "#{asset_url('image.css')}") do
            doc.div(class: 'sul-embed-image-list') do
              image = @purl_object.contents.first.files.first
              image_id = image_id(image)
              doc.div(class: 'sul-embed-osd', style: "#{('height: ' + body_height.to_s + 'px') if body_height}", id: "osd-#{image_id}", 'data-iiif-info-url' => "#{iiif_info_url(image)}") do
                doc.div(class: 'sul-embed-osd-toolbar') do
                  doc.i(class: 'fa fa-plus-circle', id: "osd-#{image_id}-zoom-in")
                  doc.i(class: 'fa fa-minus-circle', id: "osd-#{image_id}-zoom-out")
                  doc.i(class: 'fa fa-repeat', id: "osd-#{image_id}-home")
                  doc.i(class: 'fa fa-expand', id: "osd-#{image_id}-full-page")
                end
              end
            end
            doc.script { doc.text ";jQuery.getScript(\"#{asset_url('image.js')}\");" }
          end
        end.to_html
      end

      def image_id(image)
        ::File.basename(image.title, ::File.extname(image.title))
      end

      def iiif_info_url(image)
        "#{Settings.iiif_stacks_url}/image/iiif/#{@purl_object.druid}%252F#{image_id(image)}/info.json"
      end

      def default_body_height
        500
      end

      def self.supported_types
        [:image]
      end
    end
  end
end

Embed.register_viewer(Embed::Viewer::Image) if Embed.respond_to?(:register_viewer)
