# frozen_string_literal: true

class MiradorComponent < ViewComponent::Base
  def initialize(viewer:)
    @viewer = viewer
  end

  attr_reader :viewer
end
