# frozen_string_literal: true

module Embed
  class Virtex3dComponent < ViewComponent::Base
    def initialize(viewer:)
      @viewer = viewer
    end

    attr_reader :viewer
  end
end
