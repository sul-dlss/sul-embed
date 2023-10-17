# frozen_string_literal: true

module Embed
  class WasSeedComponent < ViewComponent::Base
    def initialize(viewer:)
      @viewer = viewer
    end

    attr_reader :viewer
  end
end
