# frozen_string_literal: true

module Embed
  class MediaWithCompanionWindowsComponent < ViewComponent::Base
    def initialize(viewer:)
      @viewer = viewer
    end

    attr_reader :viewer

    delegate :purl_object, to: :viewer
    delegate :citation_only?, :downloadable_files, :downloadable_transcript_files?,
             :druid, to: :purl_object

    def include_transcripts
      Settings.enabled_features.transcripts || params[:transcripts] == 'true'
    end

    def resources_with_primary_file
      @resources_with_primary_file ||= purl_object.contents.select do |purl_resource|
        purl_resource.primary_file.present?
      end
    end

    def iiif_v3_manifest_url
      "#{Settings.purl_url}/#{druid}/iiif3/manifest"
    end
  end
end
