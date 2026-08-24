# frozen_string_literal: true

module Media
  class TagComponent < ViewComponent::Base
    include Embed::StacksImage

    with_collection_parameter :resource
    SUPPORTED_MEDIA_TYPES = %i[audio video].freeze

    # @param [Purl::Resource] resource This resource is expected to have a primary file.
    # @param [#index] resource_iteration Information about what part of the collection we are in
    # @param [String] druid the object identifier
    # @param [Integer] selected_index the offset of the resource the viewer opens on
    # @param [Integer, nil] page the one-based page a PDF should open to
    def initialize(resource:, resource_iteration:, druid:, selected_index: 0, page: nil)
      @resource = resource
      @file = resource.primary_file
      @resource_iteration = resource_iteration
      @druid = druid
      @selected_index = selected_index
      @page = page
    end

    attr_reader :file, :druid, :page

    delegate :type, to: :@resource
    delegate :primary_file_url, to: :@resource

    # Whether this is the resource the viewer opens on
    def selected?
      @resource_iteration.index == @selected_index
    end

    def call
      return media_element if audio_or_video?
      return render PdfComponent.new(slot: slot(thumbnail_url), page:) if file.pdf?

      # An image resource carries no separate thumbnail file; it is its own thumbnail
      render PreviewImageComponent.new(druid:, slot: slot(own_thumbnail_url))
    end

    def audio_or_video?
      SUPPORTED_MEDIA_TYPES.include?(type.to_sym)
    end

    # @param [String, nil] thumbnail the image the content list shows for this resource
    def slot(thumbnail)
      Slot.new(file:, type:, file_uri: primary_file_url, thumbnail:, selected: selected?,
               index: @resource_iteration.index, size: @resource_iteration.size)
    end

    # the 74,73 size accounts for the additional pixel size returned by the image server
    def thumbnail_url
      stacks_square_url(druid, @resource.thumbnail.title, size: '74,73') if @resource.thumbnail
    end

    def own_thumbnail_url
      stacks_square_url(druid, file.title, size: '74,73')
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
      return asset_url('waveform-audio-poster.svg') if type == 'audio'

      asset_url('locked-media-poster.svg') unless @file.world_viewable?
    end

    def media_element # rubocop:disable Metrics/MethodLength
      render WrapperComponent.new(slot: slot(thumbnail_url)) do
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
        data: { content_type: file.mimetype, index: @resource_iteration.index, media_src: file.file_url,
                captions: caption_data },
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

    # The transcript panel fetches and parses the caption files itself instead of reading the
    # player's text tracks, which only ever expose the cues of the language on screen. It
    # needs the whole list up front, independently of the track elements above, which the
    # player detaches and re-clones while it loads.
    def caption_data
      caption_files.map do |caption|
        { language: caption.language_code, label: caption.media_caption_label, url: caption.file_url }
      end.to_json
    end

    def caption_files
      @caption_files ||= @resource.caption_files.sort_by(&:language_code)
    end
  end
end
