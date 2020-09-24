# frozen_string_literal: true

module Embed
  module Viewer
    class M3Viewer < CommonViewer
      delegate :search, :suggested_search, :canvas_id, :cdl_hold_record_id, to: :request

      def to_partial_path
        'embed/template/m3_viewer'
      end

      def self.supported_types
        %i[image manuscript map book]
      end

      def manifest_json_url
        @purl_object.manifest_json_url
      end

      def manifest_json
        @manifest_json ||= JSON.parse(@purl_object.manifest_json_response)
      end

      def show_attribution_panel?
        purl_object.collections.any? do |druid|
          Settings.collections_to_show_attribution.include?(druid)
        end
      end

      def cdl?
        purl_object.rights.controlled_digital_lending?
      end

      def canvas_index
        if request.canvas_id
          canvases = manifest_json.fetch('sequences', []).map { |seq| seq['canvases'] }.first
          canvases.index { |canvas| canvas['@id'] == request.canvas_id } || request.canvas_index
        else
          request.canvas_index
        end
      end
    end
  end
end
