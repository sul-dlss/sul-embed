module Embed
  class Viewer
    class Image
      include Embed::Viewer::CommonViewer
      include ActionView::Helpers::TagHelper
      include ActionView::Context
      include ActionView::Helpers::TextHelper
      include React::Rails::ViewHelper

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
        react_component('EmbedPanel',
                        {
                          panelType: 'EmbedPanelDownload',
                          panelClass: 'sul-embed-download-panel',
                          panelTitle: 'Download image <span class="sul-embed-panel-item-label"',
                          sizes: Constants::IMAGE_DOWNLOAD_SIZES,
                          stacksUrl: Settings.stacks_url
                        },
                        prerender: false
                       )
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
