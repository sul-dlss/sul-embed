# frozen_string_literal: true

module Embed
  module Viewer
    class Geo < CommonViewer
      def component
        new_viewer? ? GeoComponent : ::Legacy::GeoComponent
      end

      def importmap
        new_viewer? ? 'geo' : 'legacy_geo'
      end

      def stylesheet
        new_viewer? ? 'geo.css' : 'legacy_geo.css'
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
        options['data-geo-viewer-colors'] = Settings.geo_viewer_colors.to_json
        options
      end

      def self.show_download?
        true
      end

      def index_map
        purl_object.contents.map(&:files).flatten.find { |file| index_map_files.include? file.title }
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

      def index_map_files
        %w[index_map.geojson index_map.json]
      end

      def default_height
        new_viewer? ? super : '493px'
      end
    end
  end
end
