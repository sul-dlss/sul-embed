# frozen_string_literal: true

class EmbedPanelComponent < ViewComponent::Base
  def initialize(viewer:)
    @viewer = viewer
  end

  delegate :request, :purl_object, to: :viewer
  delegate :title, to: :purl_object, prefix: true

  attr_reader :viewer
end
