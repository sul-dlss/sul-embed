# frozen_string_literal: true

module Legacy
  class HeaderComponent < ViewComponent::Base
    def initialize(viewer:)
      @viewer = viewer
    end

    attr_reader :viewer

    def render?
      viewer.display_header?
    end
  end
end
