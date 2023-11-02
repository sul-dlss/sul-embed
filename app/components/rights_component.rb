# frozen_string_literal: true

class RightsComponent < ViewComponent::Base
  def initialize(viewer:)
    @viewer = viewer
  end

  attr_reader :viewer

  delegate :purl_object, to: :viewer
  delegate :use_and_reproduction, :copyright, :license, to: :purl_object
end
