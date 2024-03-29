# frozen_string_literal: true

module Embed
  module Download
    class PdfComponent < ViewComponent::Base
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
