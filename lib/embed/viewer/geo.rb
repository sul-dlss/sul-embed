module Embed
  class Viewer
    class Geo < CommonViewer

      def initialize(*args)
        super
      end

      def body_html
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-body sul-embed-geo', 'style' => "max-height: #{body_height}px", 'data-sul-embed-theme' => "#{asset_url('geo.css')}") do
            doc.div(map_element_options) {}
            doc.script { doc.text ";jQuery.getScript(\"#{asset_url('geo.js')}\");" }
          end
        end.to_html
      end

      def download_html
        return '' if @request.hide_download?
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-panel-container') do
            doc.div(class: 'sul-embed-panel sul-embed-download-panel', style: 'display:none;', :'aria-hidden' => 'true') do
              doc.div(class: 'sul-embed-panel-header') do
                doc.button(class: 'sul-embed-close', 'data-sul-embed-toggle' => 'sul-embed-download-panel') do
                  doc.span('aria-hidden' => true) do
                    doc.cdata '&times;'
                  end
                  doc.span(class: 'sul-embed-sr-only') { doc.text 'Close' }
                end
                doc.div(class: 'sul-embed-panel-title') do
                  doc.text 'Download item'
                  doc.span(class: 'sul-embed-panel-item-label')
                end
              end
              doc.div(class: 'sul-embed-panel-body') do
                @purl_object.contents.each do |resource|
                  doc.ul() do
                    resource.files.each do |file|
                      doc.li(class: "sul-embed-panel-item-label #{'sul-embed-stanford-only' if file.stanford_only?}") do
                        doc.a(href: file_url(file.title), title: file.title) do
                          doc.text file.title
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end.to_html
      end

      ##
      # Options for the map element tag
      # @return [Hash]
      def map_element_options
        options = {
          id: 'sul-embed-geo-map',
          style: "height: #{body_height}px",
          'data-bounding-box' => @purl_object.bounding_box,
        }
        if @purl_object.public?
          options['data-wms-url'] = Settings.geo_wms_url
          options['data-layers'] = "druid:#{@purl_object.druid}"
        end
        options
      end
      
      def default_body_height
        400
      end
      
      def self.supported_types
        [:geo]
      end
      
      def external_url
        "#{Settings.geo_external_url}#{@request.object_druid}"
      end
    end
  end
end

Embed.register_viewer(Embed::Viewer::Geo) if Embed.respond_to?(:register_viewer)
