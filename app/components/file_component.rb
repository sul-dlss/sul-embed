# frozen_string_literal: true

class FileComponent < ViewComponent::Base
  def initialize(viewer:)
    @viewer = viewer
  end

  attr_reader :viewer

  def message
    viewer.authorization.message
  end
end
