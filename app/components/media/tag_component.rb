# frozen_string_literal: true

module Media
  class TagComponent < ViewComponent::Base
    include Embed::StacksImage

    with_collection_parameter :resource
    SUPPORTED_MEDIA_TYPES = %i[audio video].freeze

    # @param [Purl::Resource] resource This resource is expected to have a primary file.
    # @param [#index] resource_iteration Information about what part of the collection we are in
    # @param [String] druid the object identifier
    def initialize(resource:, resource_iteration:, druid:)
      @resource = resource
      @file = resource.primary_file
      @resource_iteration = resource_iteration
      @druid = druid
    end

    attr_reader :file, :druid

    delegate :type, to: :@resource

    def call
      if SUPPORTED_MEDIA_TYPES.include?(type.to_sym)
        media_element
      else
        render PreviewImageComponent.new(druid:, file:, type:, size: @resource_iteration.size,
                                         resource_index: @resource_iteration.index)
      end
    end

    def thumbnail_url
      # the 74,73 size accounts for the additional pixel size returned by the image server
      stacks_square_url(druid, @resource.thumbnail.title, size: '74,73') if @resource.thumbnail
    end

    def poster_url_for
      return default_poster unless @resource.thumbnail

      if @resource.thumbnail.world_downloadable?
        stacks_thumb_url(druid, @resource.thumbnail.title, size: '!800,600')
      else
        stacks_thumb_url(druid, @resource.thumbnail.title)
      end
    end

    def default_poster
      return default_audio_thumbnail if type == 'audio'

      return default_video_thumbnail unless @file.world_viewable?

      nil
    end

    def default_audio_thumbnail
      asset_url('waveform-audio-poster.svg')
    end

    def default_video_thumbnail
      asset_url('locked-media-poster.svg')
    end

    def media_element # rubocop:disable Metrics/MethodLength
      render WrapperComponent.new(thumbnail: thumbnail_url, file:, type:,
                                  size: @resource_iteration.size,
                                  resource_index: @resource_iteration.index) do
        tag.div(
          style: 'height: 100%',
          data: {
            index: @resource_iteration.index,
            controller: 'media-player',
            media_player_uri_value: file.file_url,
            action: 'iiif-manifest-received@window->file-auth#parseFiles ' \
                    'media-seek@window->media-player#seek ' \
                    'fullscreenchange@window->media-player#fullscreenChange ' \
                    'auth-success@window->media-player#initializePlayer'
          }
        ) do
          tag.video_player do
            tag.video_skin do
              media_tag
            end
          end
        end
      end
    end

    def restricted?
      @file.stanford_only? || @file.location_restricted?
    end

    # We use the video preset for audio too, preserving the fading controls and
    # poster behavior that the previous Video.js integration provided.
    def media_tag # rubocop:disable Metrics/MethodLength
      tag.hlsjs_video(
        preload: restricted? ? 'none' : 'auto',
        id: "sul-embed-media-#{@resource_iteration.index}",
        poster: poster_url_for,
        playsinline: true,
        # content_type describes the direct file (media_src fallback). The streamed URL provided by
        # the probe service is always HLS, so the player controller overrides the type in that case.
        data: { content_type: file.mimetype, index: @resource_iteration.index, media_src: file.file_url },
        class: 'sul-embed-media-file',
        # So that VTT can be downloaded when download:stanford
        crossorigin: Rails.env.development? ? '' : 'use-credentials'
      ) do
        captions
      end
    end

    # Generate the video caption elements
    def captions
      return unless caption_files.any?

      # A video clip may have multiple caption files in different languages.
      # We want to enable the user to select from any of these options.
      # We also want the different language options to be listed alphabetically.
      # For Safari, we must ensure a track is selected by default to allow the track cues to be available.
      safe_join(
        caption_files.map.with_index do |caption_file, i|
          tag.track(src: caption_file.file_url, kind: 'captions',
                    srclang: caption_file.language_code, label: caption_file.media_caption_label,
                    default: (i.zero? && !caption_file.sdr_generated? ? '' : nil))
        end
      )
    end

    def caption_files
      @caption_files ||= @resource.caption_files.sort_by(&:language_code)
    end
  end
end
