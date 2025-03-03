# frozen_string_literal: true

module Legacy
  class EmbedPanelComponent < ViewComponent::Base
    def initialize(viewer:)
      @viewer = viewer
    end

    attr_reader :viewer

    def render?
      !viewer.embed_request.hide_embed_this?
    end
  end
end
