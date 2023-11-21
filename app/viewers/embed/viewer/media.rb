# frozen_string_literal: true

module Embed
  module Viewer
    class Media < CommonViewer
      def component
        # Use the new component if they provide the feature flag
        return MediaWithCompanionWindowsComponent if use_new_component?

        LegacyMediaComponent
      end

      # override CommonViewer instance method to ensure we do not show download panel when no downloadable files
      def show_download?
        super && @purl_object.downloadable_files.present?
      end

      def self.show_download?
        true
      end

      private

      def use_new_component?
        request.params[:new_component] == 'true' ||
          Settings.enabled_features.new_component
      end

      def default_height
        400
      end
    end
  end
end
