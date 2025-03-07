# frozen_string_literal: true

class FileComponent < ViewComponent::Base
  def initialize(viewer:)
    @viewer = viewer
  end

  attr_reader :viewer

  delegate :purl_object, to: :viewer
  delegate :citation_only?, :embargoed?, to: :purl_object

  def message
    viewer.authorization.message
  end

  # If this method is false, then display the "content not available" banner
  # We exclude the embargoed state, because we prefer to show the embargo banner and we don't want two banners
  def display_not_available_banner?
    citation_only? && !embargoed?
  end
end
