# frozen_string_literal: true

module Embed
  class FileComponent < ViewComponent::Base
    def initialize(viewer:)
      @viewer = viewer
    end

    attr_reader :viewer
  end
end
