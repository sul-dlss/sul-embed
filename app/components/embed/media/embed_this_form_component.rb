# frozen_string_literal: true

module Embed
  module Media
    class EmbedThisFormComponent < ViewComponent::Base
      def initialize(viewer:)
        @viewer = viewer
      end

      delegate :request, :purl_object, to: :viewer
      delegate :title, to: :purl_object, prefix: true
      delegate :purl_url, to: :purl_object

      attr_reader :viewer
    end
  end
end
