# frozen_string_literal: true

class ModelComponent < ViewComponent::Base
  def initialize(viewer:)
    @viewer = viewer
  end

  attr_reader :viewer

  delegate :purl_object, to: :viewer
end
