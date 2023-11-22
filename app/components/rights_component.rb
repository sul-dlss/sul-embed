# frozen_string_literal: true

class RightsComponent < ViewComponent::Base
  def initialize(viewer:)
    @viewer = viewer
  end

  attr_reader :viewer

  delegate :purl_object, to: :viewer
  delegate :use_and_reproduction, :copyright, :license, to: :purl_object

  def no_rights_information_present?
    use_and_reproduction.blank? &&
      copyright.blank? &&
      license.blank?
  end

  def default_attribution
    'Provided by the Stanford University Libraries'
  end

  def stanford_libraries_logo_url
    # NOTE: This is the URL Mirador already uses, so this increases parity between the
    #       image and media viewers even if it may appear brittle
    'https://stacks.stanford.edu/image/iiif/wy534zh7137/SULAIR_rosette/full/400,/0/default.jpg'
  end
end
