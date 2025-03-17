# frozen_string_literal: true

class MediaComponent < ViewComponent::Base
  def initialize(viewer:)
    @viewer = viewer
  end

  attr_reader :viewer

  delegate :purl_object, to: :viewer
  delegate :druid, :downloadable_transcript_files?, :downloadable_caption_files?, :downloadable_files, to: :purl_object

  def transcript_message
    return unless downloadable_caption_files?

    return unless downloadable_files.any? { it.caption? && it.stanford_only? }

    'Login in to view transcript'
  end

  def resources_with_primary_file
    @resources_with_primary_file ||= purl_object.contents.select do |purl_resource|
      purl_resource.primary_file.present?
    end
  end
end
