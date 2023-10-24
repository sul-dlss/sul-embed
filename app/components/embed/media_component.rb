# frozen_string_literal: true

module Embed
  class MediaComponent < ViewComponent::Base
    def initialize(viewer:)
      @viewer = viewer
    end

    attr_reader :viewer

    delegate :purl_object, to: :viewer
    delegate :druid, to: :purl_object

    def include_transcripts
      Settings.enabled_features.transcripts || params[:transcripts] == 'true'
    end

    def primary_files_count
      purl_object.contents.count do |resource|
        resource.primary_file.present?
      end
    end

    def many_primary_files?
      primary_files_count > 1
    end
  end
end
