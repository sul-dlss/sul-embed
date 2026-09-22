# frozen_string_literal: true

module Embed
  module Viewer
    class Media < CommonViewer
      def component
        MediaComponent
      end

      def importmap
        'media'
      end

      # The resources the viewer draws, in the order they appear in the content list.
      # A resource without a primary file has nothing we know how to display.
      #
      # @return [Array<Embed::Purl::Resource>]
      def displayable_resources
        @displayable_resources ||= purl_object.contents.select { |resource| resource.primary_file.present? }
      end

      # The resource the viewer opens on. Falls back to the first one when no filename was
      # requested, or when the requested one is not a resource we can display.
      #
      # @return [Integer]
      def selected_index
        @selected_index ||= requested_index || 0
      end

      # @return [String, nil] the URL identifying the selected resource in the IIIF manifest
      def selected_file_url
        displayable_resources[selected_index]&.primary_file_url
      end

      private

      def requested_index
        return if embed_request.filename.blank?

        displayable_resources.index { |resource| resource.primary_file.filename == embed_request.filename }
      end
    end
  end
end
