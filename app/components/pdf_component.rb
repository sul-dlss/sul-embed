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

  # chromium has a bug preventing the esc key from exiting full screen in some situations, see
  # https://issues.chromium.org/issues/40131988 and https://github.com/sul-dlss/sul-embed/issues/2162
  def requested_by_chromium?
    %r{(Chrome|Edg)/\d+}.match?(request.headers['User-Agent'])
  end
end
