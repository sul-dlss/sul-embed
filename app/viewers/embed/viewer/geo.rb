# frozen_string_literal: true

module Embed
  module Viewer
    class Geo < CommonViewer
      def to_partial_path
        'embed/template/geo'
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
