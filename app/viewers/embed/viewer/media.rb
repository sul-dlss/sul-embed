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

      private

      def default_height
        400
      end
    end
  end
end
