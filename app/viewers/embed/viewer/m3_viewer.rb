# frozen_string_literal: true

module Embed
  module Viewer
    class M3Viewer < CommonViewer
      delegate :search, :suggested_search, :canvas_id, :cdl_hold_record_id, :workspace_state, to: :embed_request

      def component
        M3Component
      end

      def stylesheet
        'm3.css'
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
        purl_object.controlled_digital_lending?
      end

      # We rewrite the provided canvas ids to:
      # - ensure it exists in the manifest (if they don't, mirador puts the user into a weird initial state)
      # - rewrite pre-cocina canvas ids to post-cocina canvas ids as appropriate
      #        (to avoid breaking embeds that used to work)
      # rubocop:disable Metrics/AbcSize
      def canvas_id
        return if embed_request.canvas_id.blank?

        if canvases.any? { |canvas| canvas['@id'] == embed_request.canvas_id }
          embed_request.canvas_id
        elsif cocinafied_canvases? && embed_request.canvas_id.exclude?('cocina-fileSet')
          cocinafied_canvas_id
        else
          Honeybadger.notify(
            "Unable to find requested canvas id '#{embed_request.canvas_id}' in manifest for #{purl_object.druid}"
          )

          nil
        end
      end
      # rubocop:enable Metrics/AbcSize

      def canvas_index
        if canvas_id
          canvases.index { |canvas| canvas['@id'] == canvas_id } || embed_request.canvas_index
        else
          embed_request.canvas_index
        end
      end

      private

      def canvases
        manifest_json.fetch('sequences', []).pick('canvases')
      end

      def cocinafied_canvases?
        canvases.any? do |canvas|
          canvas['@id'].include?('cocina-fileSet')
        end
      end

      def cocinafied_canvas_id
        base, _, resource_id = embed_request.canvas_id.rpartition('/')

        potential_canvas_id = base + "/cocina-fileSet-#{purl_object.druid}-#{resource_id}"

        potential_canvas_id if canvases.any? { |canvas| canvas['@id'] == potential_canvas_id }
      end
    end
  end
end
