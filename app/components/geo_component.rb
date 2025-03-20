# frozen_string_literal: true

class GeoComponent < ViewComponent::Base
  def initialize(viewer:)
    @viewer = viewer
  end

  attr_reader :viewer

  delegate :purl_object, to: :viewer
  delegate :druid, :public?, to: :purl_object

  def data_actions
    return if public?

    'iiif-manifest-received@window->file-auth#parseFiles auth-success@window->geo#show'
  end
end
