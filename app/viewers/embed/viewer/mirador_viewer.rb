# frozen_string_literal: true

module Embed
  module Viewer
    class MiradorViewer < CommonViewer
      delegate :search, :suggested_search, :iiif_initial_viewer_config,
               to: :embed_request

      def component
        MiradorComponent
      end

      def stylesheet
        'mirador.css'
      end

      delegate :manifest_json_url, to: :@purl_object

      # A scanned map may carry a georeference annotation saying where on a map it belongs. When it
      # does, the viewer offers the map as a second way of looking at the same object - see
      # georeferencePlugin. The v3 manifest goes along because a manifest can carry the annotation
      # itself, and that copy is the more current of the two when both exist.
      delegate :iiif_georeference_annotations?, :georeference_annotations_url, :iiif_v3_manifest_url,
               to: :purl_object

      # What to call each of those views. Translated here rather than written into the plugin because
      # the Vite bundle has no way to read Rails' translations, and this is where the rest of
      # sul-embed's strings live. JSON so one attribute carries however many views there turn out to
      # be, the same way data-viewer-config carries Mirador's own.
      def view_labels
        I18n.t('views', scope: i18n_path).to_json if iiif_georeference_annotations?
      end

      def manifest_json
        @manifest_json ||= JSON.parse(@purl_object.manifest_json_response)
      end

      def show_attribution_panel?
        purl_object.collections.intersect?(Settings.collections_to_show_attribution)
      end

      def cdl?
        purl_object.controlled_digital_lending?
      end

      # We rewrite the provided canvas ids to:
      # - ensure it exists in the manifest (if they don't, mirador puts the user into a weird initial state)
      # - rewrite pre-cocina canvas ids to post-cocina canvas ids as appropriate
      #        (to avoid breaking embeds that used to work)
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
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
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

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
