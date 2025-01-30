# frozen_string_literal: true

module Legacy
  class GeoComponent < ViewComponent::Base
    def initialize(viewer:)
      @viewer = viewer
    end

    attr_reader :viewer
  end
end
