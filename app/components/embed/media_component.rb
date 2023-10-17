# frozen_string_literal: true

module Embed
  class MediaComponent < ViewComponent::Base
    def initialize(viewer:)
      @viewer = viewer
    end

    attr_reader :viewer
  end
end
