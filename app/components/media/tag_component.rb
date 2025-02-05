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
      render WrapperComponent.new(thumbnail: thumbnail_url, file:, type:,
                                  size: @resource_iteration.size,
                                  resource_index: @resource_iteration.index) do
        media_tag
      end
    end

    def media_tag_name
      safari_wants_audio_with_captions? ? 'video' : type
    end

    def safari_wants_audio_with_captions?
      type == 'audio' && render_captions? && webkit_useragent?
    end

    # Many user agents include "safari"
    # Tested with:
    # rubocop:disable Layout/LineLength
    # Firefox: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:134.0) Gecko/20100101 Firefox/134.0"
    # Edge: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36 Edg/132.0.0.0'
    # iOS Safari: "Mozilla/5.0 (iPhone; CPU iPhone OS 18_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.2 Mobile/15E148 Safari/604.1"
    # MacOS Safari: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.3 Safari/605.1.15"
    # rubocop:enable Layout/LineLength
    def webkit_useragent?
      /^((?!chrome|android).)*safari/i.match?(request.headers['User-Agent'])
    end

    def media_tag
      tag.send(media_tag_name,
               id: "sul-embed-media-#{@resource_iteration.index}",
               data: data_attributes,
               poster: poster_url_for,
               controls: 'controls',
               class: 'sul-embed-media-file',
               crossorigin: 'use-credentials', # So that VTT can be downloaded when download:stanford
               height: '100%') do
        streaming_source + captions
      end
    end

    def data_attributes
      attrs = {
        auth_url: authentication_url,
        index: @resource_iteration.index,
        media_tag_target: 'authorizeableResource',
        controller: 'media-player',
        action: 'media-seek@window->media-player#seek ' \
                'auth-success@window->media-player#initializeVideoJSPlayer'
      }

      # Firefox displays "No video with supported format and MIME type found" if the video is "Stanford-only"
      attrs[:setup] = { preload: 'none' } if restricted? && firefox?

      attrs
    end

    def restricted?
      @file.stanford_only? || @file.location_restricted?
    end

    def firefox?
      request.headers['User-Agent'].include?('Firefox')
    end

    def streaming_source
      type = Rails.env.development? ? file.mimetype : 'application/x-mpegURL'
      stacks_media_stream = Embed::StacksMediaStream.new(druid:, file:)
      tag.source(src: stacks_media_stream.to_playlist_url, type:)
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
