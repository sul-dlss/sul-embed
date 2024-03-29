# frozen_string_literal: true

module Embed
  module Media
    class MetadataComponent < ViewComponent::Base
      def initialize(viewer:)
        @viewer = viewer
      end

      attr_reader :viewer
    end
  end
end
