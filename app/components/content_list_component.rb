# frozen_string_literal: true

class ContentListComponent < ViewComponent::Base
  def initialize(viewer:, heading:)
    @viewer = viewer
    @heading = heading
  end

  attr_reader :viewer, :heading
end
