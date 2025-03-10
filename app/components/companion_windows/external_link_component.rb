# frozen_string_literal: true

module CompanionWindows
  class ExternalLinkComponent < ViewComponent::Base
    def initialize(viewer:, label:)
      @viewer = viewer
      @label = label
    end

    attr_reader :viewer, :label

    delegate :external_url, to: :viewer

    def stimulus_attributes
      return unless viewer.instance_of?(::Embed::Viewer::Geo)

      { controller: 'meta-check', meta_check_url_value: viewer.purl_object.meta_json_url }
    end
  end
end
