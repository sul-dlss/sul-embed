# frozen_string_literal: true

module Embed
  module LegacyMedia
    class MediaTagComponent < ViewComponent::Base # rubocop:disable Metrics:ClassLength
      include StacksImage
      with_collection_parameter :resource
      SUPPORTED_MEDIA_TYPES = %i[audio video].freeze

      # @param [Purl::Resource] resource This resource is expected to have a primary file.
      # @param [#index] resource_iteration Information about what part of the collection we are in
      # @param [String] druid the object identifier
      # @param [Bool] include_transcripts a feature flag about displaying VTT tracks
      # @param [Bool] many_primary_files should we add the sul-embed-many-media class
      def initialize(resource:, resource_iteration:, druid:, include_transcripts:, many_primary_files:)
        @resource = resource
        @file = resource.primary_file
        @resource_iteration = resource_iteration
        @druid = druid
        @include_transcripts = include_transcripts
        @many_primary_files = many_primary_files
      end

      attr_reader :file

      delegate :type, to: :@resource
      delegate :stanford_only?, :location_restricted?, to: :file

      def call
        if SUPPORTED_MEDIA_TYPES.include?(type.to_sym)
          media_element
        else
          previewable_element
        end
      end

      def thumbnail_url
        stacks_square_url(@druid, @resource.thumbnail.title, size: '75') if @resource.thumbnail
      end

      def poster_url_for
        return default_audio_thumbnail if type == 'audio' && !@resource.thumbnail
        return unless @resource.thumbnail

        if @resource.thumbnail.world_downloadable?
          stacks_thumb_url(@druid, @resource.thumbnail.title, size: '!800,600')
        else
          stacks_thumb_url(@druid, @resource.thumbnail.title)
        end
      end

      def default_audio_thumbnail
        asset_url('waveform-audio-poster.svg')
      end

      def media_element
        render MediaWrapperComponent.new(thumbnail: thumbnail_url, file:, type:,
                                         resource_index: @resource_iteration.index) do
          access_restricted_overlay + media_tag
        end
      end

      def media_tag_name
        safari_wants_audio_with_captions? ? 'video' : type
      end

      def safari_wants_audio_with_captions?
        type == 'audio' && request.headers['User-Agent'].include?('Safari') && render_captions?
      end

      def media_tag # rubocop:disable Metrics/MethodLength
        tag.send(media_tag_name,
                 id: "sul-embed-media-#{@resource_iteration.index}",
                 data: {
                   auth_url: authentication_url
                 },
                 poster: poster_url_for,
                 controls: 'controls',
                 crossorigin: 'anonymous',
                 aria: { labelledby: "access-restricted-message-div-#{@resource_iteration.index}" },
                 class: "sul-embed-media-file #{'sul-embed-many-media' if @many_primary_files}",
                 height: '100%') do
          enabled_streaming_sources + captions
        end
      end

      def previewable_element
        thumb_url = stacks_square_url(@druid, file.title, size: '75')
        render MediaWrapperComponent.new(thumbnail: thumb_url, file:, type:, resource_index: @resource_iteration.index,
                                         scroll: true) do
          tag.img(src: stacks_thumb_url(@druid, file.title),
                  class: "sul-embed-media-thumb #{'sul-embed-many-media' if @many_primary_files}")
        end
      end

      def enabled_streaming_sources
        safe_join(
          enabled_streaming_types.map do |streaming_type|
            tag.source(src: streaming_url_for(streaming_type),
                       type: streaming_settings_for(streaming_type)[:mimetype])
          end
        )
      end

      # Generate the video caption elements
      def captions
        return unless render_captions?

        # A video clip may have multiple caption files in different languages.
        # We want to enable the user to select from any of these options.
        # We also want the different language options to be listed alphabetically.
        safe_join(
          @resource.caption_files.map do |caption_file|
            tag.track(src: caption_file.file_url, kind: 'captions',
                      srclang: caption_file.language_code, label: caption_file.language_label)
          end
        )
      end

      def render_captions?
        @include_transcripts && @resource.caption_files.any?
      end

      # NOTE: This is only for the legacy media player. We can remove it when we switch to the new player.
      def access_restricted_message
        if location_restricted? && !stanford_only?
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

      # NOTE: This is only for the legacy media player. We can remove it when we switch to the new player.
      def access_restricted_overlay
        return ''.html_safe unless stanford_only? || location_restricted?

        # TODO: line1 and line1 spans should be populated by values returned from stacks
        html = <<~HTML
          <div class='sul-embed-media-access-restricted-container' data-access-restricted-message>
            <div class='sul-embed-media-access-restricted' id="access-restricted-message-div-#{@resource_iteration.index}">
              #{access_restricted_message}
            </div>
          </div>
        HTML
        html.html_safe # rubocop:disable Rails/OutputSafety
      end

      def streaming_settings_for(streaming_type)
        Settings.streaming[streaming_type] || {}
      end

      def enabled_streaming_types
        Settings.streaming[:source_types]
      end

      def streaming_url_for(streaming_type)
        stacks_media_stream = Embed::StacksMediaStream.new(druid: @druid, file:)
        case streaming_type.to_sym
        when :hls
          stacks_media_stream.to_playlist_url
        when :flash
          stacks_media_stream.to_rtmp_url
        when :dash
          stacks_media_stream.to_manifest_url
        end
      end

      def authentication_url
        attributes = { host: Settings.stacks_url, druid: @druid, title: file.title }
        Settings.streaming.auth_url % attributes
      end
    end
  end
end
