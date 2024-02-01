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

      # The heading shown in the Content List of the CompanionWindowComponent
      def content_heading
        'Media content'
      end

      private

      def default_height
        400
      end
    end
  end
end
