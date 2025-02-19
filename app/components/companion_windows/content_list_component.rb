# frozen_string_literal: true

module CompanionWindows
  class ContentListComponent < ViewComponent::Base
    def initialize(viewer:)
      @viewer = viewer
    end

    attr_reader :viewer
  end
end
