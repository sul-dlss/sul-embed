# frozen_string_literal: true

class EmbedPanelComponent < ViewComponent::Base
  def initialize(viewer:)
    @viewer = viewer
  end

  attr_reader :viewer
end
