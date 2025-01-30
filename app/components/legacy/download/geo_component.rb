# frozen_string_literal: true

module Legacy
  module Download
    class GeoComponent < ViewComponent::Base
      def initialize(viewer:)
        @viewer = viewer
      end

      attr_reader :viewer
    end
  end
end
