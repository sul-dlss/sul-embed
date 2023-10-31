# frozen_string_literal: true

class MetadataListComponent < ViewComponent::Base
  def initialize(viewer:)
    @viewer = viewer
  end

  attr_reader :viewer

  delegate :purl_object, to: :viewer
  delegate :use_and_reproduction, :copyright, :license, :purl_url, to: :purl_object

  def purl_url_display
    purl_url.gsub(%r{^https?://}, '')
  end
end
