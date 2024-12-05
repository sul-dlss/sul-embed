# frozen_string_literal: true

module Embed
  class MediaTagComponent < ViewComponent::Base
    include StacksImage
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
        render MediaPreviewImageComponent.new(druid:, file:, type:, resource_index: @resource_iteration.index)
      end
    end

    def thumbnail_url
      # the 74,73 size accounts for the additional pixel size returned by the image server
      stacks_square_url(druid, @resource.thumbnail.title, size: '74,73') if @resource.thumbnail
    end

    def poster_url_for
      return default_audio_thumbnail if type == 'audio' && !@resource.thumbnail
      return unless @resource.thumbnail

      if @resource.thumbnail.world_downloadable?
        stacks_thumb_url(druid, @resource.thumbnail.title, size: '!800,600')
      else
        stacks_thumb_url(druid, @resource.thumbnail.title)
      end
    end

    def default_audio_thumbnail
      asset_url('waveform-audio-poster.svg')
    end

    def media_element
      render MediaWrapperComponent.new(thumbnail: thumbnail_url, file:, type:,
                                       resource_index: @resource_iteration.index) do
        media_tag
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
                 auth_url: authentication_url,
                 media_tag_target: 'authorizeableResource',
                 controller: 'media-player',
                 action: 'media-seek@window->media-player#seek ' \
                         'auth-success@window->media-player#initializeVideoJSPlayer'
               },
               poster: poster_url_for,
               controls: 'controls',
               class: 'sul-embed-media-file',
               height: '100%') do
        streaming_source + captions
      end
    end

    def streaming_source
      stacks_media_stream = Embed::StacksMediaStream.new(druid:, file:)
      tag.source(src: stacks_media_stream.to_playlist_url, type: 'application/x-mpegURL')
    end

    # Generate the video caption elements
    def captions
      return unless render_captions?

      # A video clip may have multiple caption files in different languages.
      # We want to enable the user to select from any of these options.
      # We also want the different language options to be listed alphabetically.
      # For Safari, we must ensure a track is selected by default to allow the track cues to be available.
      safe_join(
        @resource.caption_files.map.with_index do |caption_file, i|
          tag.track(src: caption_file.file_url, kind: 'captions',
                    srclang: caption_file.language_code, label: caption_file.media_caption_label,
                    default: (i.zero? && !caption_file.sdr_generated? ? '' : nil))
        end
      )
    end

    def render_captions?
      @resource.caption_files.any?
    end

    def authentication_url
      attributes = { host: Settings.stacks_url, druid:, title: file.title }
      Settings.streaming.auth_url % attributes
    end
  end
end
