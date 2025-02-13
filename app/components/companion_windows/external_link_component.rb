# frozen_string_literal: true

module CompanionWindows
  class ExternalLinkComponent < ViewComponent::Base
    def initialize(viewer:, label:)
      @viewer = viewer
      @label = label
    end

    attr_reader :viewer, :label

    delegate :external_url, to: :viewer
  end
end
