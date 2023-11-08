# frozen_string_literal: true

class EmbedThisFormComponent < ViewComponent::Base
  def initialize(viewer:)
    @viewer = viewer
  end

  delegate :request, :purl_object, to: :viewer
  delegate :title, to: :purl_object, prefix: true
  delegate :purl_url, to: :purl_object

  attr_reader :viewer
end
