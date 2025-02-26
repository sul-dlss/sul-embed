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
    end
  end
end
