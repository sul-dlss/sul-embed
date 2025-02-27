# frozen_string_literal: true

class ModelComponent < ViewComponent::Base
  def initialize(viewer:)
    @viewer = viewer
  end

  attr_reader :viewer

  delegate :purl_object, to: :viewer

  def viewable_content?
    viewer.three_dimensional_files.any?
  end

  def message
    viewer.authorization.message
  end
end
