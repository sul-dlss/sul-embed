# frozen_string_literal: true

class FileComponent < ViewComponent::Base
  def initialize(viewer:)
    @viewer = viewer
  end

  attr_reader :viewer

  delegate :purl_object, to: :viewer
  delegate :druid, to: :purl_object
end
