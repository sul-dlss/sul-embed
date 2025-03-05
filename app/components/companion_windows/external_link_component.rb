# frozen_string_literal: true

module CompanionWindows
  class ExternalLinkComponent < ViewComponent::Base
    def initialize(viewer:, label:)
      @viewer = viewer
      @label = label
    end

    attr_reader :viewer, :label

    delegate :external_url, to: :viewer

    def render?
      return true unless viewer.instance_of?(::Embed::Viewer::Geo)

      Embed::MetaJson.new(purl_object: viewer.purl_object).earthworks?
    end
  end
end
