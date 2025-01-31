# frozen_string_literal: true

class PdfComponent < ViewComponent::Base
  def initialize(viewer:)
    @viewer = viewer
  end

  attr_reader :viewer

  delegate :purl_object, to: :viewer
  delegate :druid, to: :purl_object

  def iiif_v3_manifest_url
    "#{Settings.purl_url}/#{druid}/iiif3/manifest"
  end
end
