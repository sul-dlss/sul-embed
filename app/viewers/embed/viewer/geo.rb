# frozen_string_literal: true

module Embed
  module Viewer
    class Geo < CommonViewer
      def component
        GeoComponent
      end

      def importmap
        'geo'
      end

      def stylesheet
        'geo.css'
      end

      ##
      # Options for the map element tag
      # @return [Hash]
      def map_element_options # rubocop:disable Metrics/AbcSize
        options = {
          id: 'sul-embed-geo-map',
          style: 'flex: 1',
          'data-bounding-box' => @purl_object.bounding_box.to_s,
          'data-geo-viewer-colors' => Settings.geo_viewer_colors.to_json
        }.compact_blank

        if index_map?
          options['data-index-map'] = index_map.file_url
        elsif geo_json?
          options['data-geo-json'] = geo_json.file_url
          options['data-layer-type'] = @purl_object.layer_type
        elsif pmtiles?
          options['data-pmtiles'] = pmtiles.file_url
        elsif cog?
          options['data-cog-url'] = cog_url
        elsif iiif_annotations?
          options['data-annotations-url'] = annotations_url
        end
        options
      end

      def self.show_download?
        true
      end

      def pmtiles?
        pmtiles.present?
      end

      def pmtiles
        purl_object.contents.map(&:files).flatten.find(&:pmtiles?)
      end

      def index_map
        purl_object.contents.map(&:files).flatten.find { |file| index_map_files.include? file.title }
      end

      def index_map?
        index_map.present?
      end

      def geo_json?
        geo_json.present?
      end

      def geo_json
        purl_object.contents.map(&:files).flatten.find(&:geo_json?)
      end

      def cog_url
        @cog_url ||= purl_object.contents.map(&:files).flatten.find(&:cog?)&.file_url
      end

      def cog?
        cog_url.present?
      end

      delegate :iiif_annotations?, to: :purl_object

      def annotations_url
        @annotations_url ||= purl_object.downloadable_files.find(&:annotations?)&.file_url
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
    end
  end
end
