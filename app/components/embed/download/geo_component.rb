# frozen_string_literal: true

module Embed
  module Download
    class GeoComponent < ViewComponent::Base
      def initialize(viewer:)
        @viewer = viewer
      end

      attr_reader :viewer
    end
  end
end
