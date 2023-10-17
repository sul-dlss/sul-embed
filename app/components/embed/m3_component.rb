# frozen_string_literal: true

module Embed
  class M3Component < ViewComponent::Base
    def initialize(viewer:)
      @viewer = viewer
    end

    attr_reader :viewer
  end
end
