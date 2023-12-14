# frozen_string_literal: true

module Embed
  class MediaComponent < ViewComponent::Base
    def initialize(viewer:)
      @viewer = viewer
    end

    attr_reader :viewer

    delegate :purl_object, to: :viewer
    delegate :druid, to: :purl_object

    def resources_with_primary_file
      @resources_with_primary_file ||= purl_object.contents.select do |purl_resource|
        purl_resource.primary_file.present?
      end
    end
  end
end
