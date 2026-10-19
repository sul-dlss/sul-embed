# frozen_string_literal: true

module Media
  # Displays an audio or video resource in the Video.js player, along with its poster and captions.
  class PlayerComponent < ViewComponent::Base
    include Embed::StacksImage

    # @param [Purl::Resource] resource the audio or video resource, which supplies its thumbnail and captions
    # @param [String] druid the object identifier
    # @param [Media::Slot] slot the resource this component draws
    def initialize(resource:, druid:, slot:)
      @resource = resource
      @druid = druid
      @slot = slot
    end

    attr_reader :druid, :slot

    delegate :file, :type, :index, to: :slot

    def call # rubocop:disable Metrics/MethodLength
      render WrapperComponent.new(slot:) do
        tag.div(
          style: 'height: 100%',
          data: {
            index:,
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
      file.stanford_only? || file.location_restricted?
    end

    # We use the video preset for audio too, preserving the fading controls and
    # poster behavior that the previous Video.js integration provided.
    def media_tag # rubocop:disable Metrics/MethodLength
      tag.hlsjs_video(
        preload: restricted? ? 'none' : 'auto',
        id: "sul-embed-media-#{index}",
        poster: poster_url,
        playsinline: true,
        # content_type describes the direct file (media_src fallback). The streamed URL provided by
        # the probe service is always HLS, so the player controller overrides the type in that case.
        data: { content_type: file.mimetype, index:, media_src: file.file_url,
                captions: caption_data },
        class: 'sul-embed-media-file',
        # So that VTT can be downloaded when download:stanford
        crossorigin: Rails.env.development? ? '' : 'use-credentials'
      ) do
        captions
      end
    end

    def poster_url
      return default_poster unless @resource.thumbnail

      if @resource.thumbnail.world_downloadable?
        stacks_thumb_url(druid, @resource.thumbnail.title, size: '!800,600')
      else
        stacks_thumb_url(druid, @resource.thumbnail.title)
      end
    end

    def default_poster
      return asset_url('waveform-audio-poster.svg') if type == 'audio'

      asset_url('locked-media-poster.svg') unless file.world_viewable?
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
