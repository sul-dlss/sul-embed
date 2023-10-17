# frozen_string_literal: true

class EmbedPanelComponent < ViewComponent::Base
  def initialize(viewer:)
    @viewer = viewer
  end

  delegate :height, :width, :request, :iframe_title, :purl_object, to: :viewer
  delegate :title, to: :purl_object, prefix: true
  delegate :druid, to: :purl_object
  attr_reader :viewer

  def iframe_component
    IframeComponent.new(viewer:)
  end

  def width_style
    width ? "#{width}px" : '100%'
  end

  def height_style
    request.fullheight? ? '100%' : "#{height}px"
  end
end
