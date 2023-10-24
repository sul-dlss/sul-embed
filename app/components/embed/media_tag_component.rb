# frozen_string_literal: true

module Embed
  class MediaTagComponent < ViewComponent::Base # rubocop:disable Metrics:ClassLength
    include StacksImage
    with_collection_parameter :resource
    SUPPORTED_MEDIA_TYPES = %i[audio video].freeze

    def initialize(resource:, resource_iteration:, druid:, include_transcripts:, many_primary_files:)
      @resource = resource
      @resource_iteration = resource_iteration
      @druid = druid
      @include_transcripts = include_transcripts
      @many_primary_files = many_primary_files
    end

    delegate :primary_file, :type, to: :@resource

    def render?
      primary_file.present?
    end

    def call
      if SUPPORTED_MEDIA_TYPES.include?(type.to_sym)
        media_element(primary_file, type)
      else
        previewable_element(primary_file)
      end
    end

    def media_element(file, type)
      file_thumb = stacks_square_url(@druid, file.thumbnail.title, size: '75') if file.thumbnail
      render MediaWrapperComponent.new(thumbnail: file_thumb, file:, file_index: @resource_iteration.index) do
        access_restricted_overlay(file.try(:stanford_only?), file.try(:location_restricted?)) +
          media_tag(file, type)
      end
    end

    def media_tag(file, type) # rubocop:disable Metrics/MethodLength
      tag.send(type,
               id: "sul-embed-media-#{@resource_iteration.index}",
               data: {
                 src: streaming_url_for(file, :dash),
                 auth_url: authentication_url(file)
               },
               poster: poster_attribute(file),
               controls: 'controls',
               crossorigin: 'anonymous',
               aria: { labelledby: "access-restricted-message-div-#{@resource_iteration.index}" },
               class: "sul-embed-media-file #{'sul-embed-many-media' if @many_primary_files}",
               height: '100%') do
        enabled_streaming_sources(file) + transcript(file)
      end
    end

    def previewable_element(file)
      thumb_url = stacks_square_url(@druid, file.title, size: '75')
      render MediaWrapperComponent.new(thumbnail: thumb_url, file:, file_index: @resource_iteration.index,
                                       scroll: true) do
        tag.img(src: stacks_thumb_url(@druid, file.title),
                class: "sul-embed-media-thumb #{'sul-embed-many-media' if @many_primary_files}")
      end
    end

    def enabled_streaming_sources(file)
      safe_join(
        enabled_streaming_types.map do |streaming_type|
          tag.source(src: streaming_url_for(file, streaming_type),
                     type: streaming_settings_for(streaming_type)[:mimetype])
        end
      )
    end

    def transcript(file)
      return unless @include_transcripts && file.vtt

      tag.track(src: file.vtt.file_url, default: true)
    end

    def poster_attribute(file)
      return unless file.thumbnail

      if file.thumbnail.world_downloadable?
        stacks_thumb_url(@druid, file.thumbnail.title, size: '!800,600')
      else
        stacks_thumb_url(@druid, file.thumbnail.title)
      end
    end

    def access_restricted_message(stanford_only, location_restricted)
      if location_restricted && !stanford_only
        <<~HTML
          <span class='line1'>Restricted media cannot be played in your location.</span>
          <span class='line2'>See Access conditions for more information.</span>
        HTML
      else
        <<~HTML
          <span class='line1'>Limited access for<br>non-Stanford guests.</span>
          <span class='line2'>See Access conditions for more information.</span>
        HTML
      end
    end

    def access_restricted_overlay(stanford_only, location_restricted)
      return ''.html_safe unless stanford_only || location_restricted

      # TODO: line1 and line1 spans should be populated by values returned from stacks
      html = <<~HTML
        <div class='sul-embed-media-access-restricted-container' data-access-restricted-message>
          <div class='sul-embed-media-access-restricted' id="access-restricted-message-div-#{@resource_iteration.index}">
            #{access_restricted_message(stanford_only, location_restricted)}
          </div>
        </div>
      HTML
      html.html_safe
    end

    def streaming_settings_for(type)
      Settings.streaming[type] || {}
    end

    def enabled_streaming_types
      Settings.streaming[:source_types]
    end

    def streaming_url_for(file, type)
      stacks_media_stream = Embed::StacksMediaStream.new(druid: @druid, file_name: file.title)
      case type.to_sym
      when :hls
        stacks_media_stream.to_playlist_url
      when :flash
        stacks_media_stream.to_rtmp_url
      when :dash
        stacks_media_stream.to_manifest_url
      end
    end

    def authentication_url(file)
      attributes = { host: Settings.stacks_url, druid: @druid, title: file.title }
      Settings.streaming.auth_url % attributes
    end
  end
end
