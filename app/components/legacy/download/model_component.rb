# frozen_string_literal: true

module Legacy
  module Download
    class ModelComponent < ViewComponent::Base
      def initialize(viewer:)
        @viewer = viewer
      end

      attr_reader :viewer

      def render?
        viewer.show_download?
      end
    end
  end
end
