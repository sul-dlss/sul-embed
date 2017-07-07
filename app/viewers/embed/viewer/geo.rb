module Embed
  module Viewer
    class Geo < CommonViewer
      def to_partial_path
        'embed/template/geo'
      end

      def body_html
        Deprecation.warn(self, 'body_html is deprecated')

        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-body sul-embed-geo', 'style' => "max-height: #{body_height}px", 'data-sul-embed-theme' => asset_url('geo.css').to_s) do
            doc.div(map_element_options) {}
            doc.script { doc.text ";jQuery.getScript(\"#{asset_url('geo.js')}\");" }
          end
        end.to_html
      end

      def download_html
        Deprecation.warn(self, 'download_html is deprecated')

        return '' if @request.hide_download?
        Embed::DownloadPanel.new do
          Nokogiri::HTML::Builder.new do |doc|
            doc.div(class: 'sul-embed-panel-body') do
              @purl_object.contents.each do |resource|
                doc.ul(class: 'sul-embed-download-list') do
                  resource.files.each do |file|
                    doc.li do
                      doc.a(href: file_url(file.title), title: file.title, target: '_blank', rel: 'noopener noreferrer', download: nil) do
                        doc.text "Download #{file.title}"
                      end
                      doc << " #{restrictions_text_for_file(file)}"
                    end
                  end
                end
              end
            end
          end.to_html
        end.to_html
      end

      ##
      # Options for the map element tag
      # @return [Hash]
      def map_element_options
        options = {
          id: 'sul-embed-geo-map',
          style: "height: #{body_height}px",
          'data-bounding-box' => @purl_object.bounding_box.to_s
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

      def self.show_download?
        true
      end

      def external_url
        "#{Settings.geo_external_url}#{@request.object_druid}"
      end

      def external_url_text
        'View this in EarthWorks'
      end
    end
  end
end
