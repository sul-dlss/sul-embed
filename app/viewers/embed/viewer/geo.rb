# frozen_string_literal: true

module Embed
  module Viewer
    class Geo < CommonViewer
      def component
        GeoComponent
      end

      ##
      # Options for the map element tag
      # @return [Hash]
      def map_element_options
        options = {
          id: 'sul-embed-geo-map',
          style: 'flex: 1',
          'data-bounding-box' => @purl_object.bounding_box.to_s
        }
        if @purl_object.public?
          options['data-wms-url'] = Settings.geo_wms_url
          options['data-layers'] = "druid:#{@purl_object.druid}"
        end
        options['data-index-map'] = index_map.file_url if index_map?
        options
      end

      def stylesheet
        'geo.css'
      end

      def self.show_download?
        true
      end

      def index_map
        purl_object.contents.map(&:files).flatten.find { |file| file.title == 'index_map.json' }
      end

      def index_map?
        index_map.present?
      end

      # Returns true or false whether the viewer should display the Download All
      # link. True for all geo objects, unless there is only one file
      # (because the file download link will suffice for that)
      def display_download_all?
        @purl_object.downloadable_files.length > 1
      end

      def external_url
        "#{Settings.geo_external_url}#{@embed_request.object_druid}"
      end

      def external_url_text
        'View this in EarthWorks'
      end

      private

      def default_height
        493
      end
    end
  end
end
