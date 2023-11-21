# frozen_string_literal: true

module Embed
  class MediaTagComponent < ViewComponent::Base # rubocop:disable Metrics:ClassLength
    include StacksImage
    with_collection_parameter :resource
    SUPPORTED_MEDIA_TYPES = %i[audio video].freeze
    # Hardcoding some language code to label mappings, based on the mappings we currently need.
    # This approach should be revisited once we have more robust BCP 47 code to label mapping integrated.
    FILE_LANGUAGE_CAPTION_LABELS = {
      'en' => 'English',
      'ru' => 'Russian',
      'de' => 'German',
      'et' => 'Estonian',
      'lv' => 'Latvian',
      'es' => 'Spanish'
    }.freeze

    # @param [Purl::Resource] resource This resource is expected to have a primary file.
    # @param [#index] resource_iteration Information about what part of the collection we are in
    # @param [String] druid the object identifier
    # @param [Bool] include_transcripts a feature flag about displaying VTT tracks
    def initialize(resource:, resource_iteration:, druid:, include_transcripts:)
      @resource = resource
      @file = resource.primary_file
      @resource_iteration = resource_iteration
      @druid = druid
      @include_transcripts = include_transcripts
    end

    attr_reader :file

    delegate :type, to: :@resource

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
      render MediaWrapperComponent.new(thumbnail: thumbnail_url, file:, type:, file_index: @resource_iteration.index) do
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
                 src: streaming_url_for(:dash),
                 auth_url: authentication_url,
                 media_tag_target: 'mediaTag'
               },
               poster: poster_url_for,
               controls: 'controls',
               crossorigin: 'anonymous',
               class: 'sul-embed-media-file',
               height: '100%') do
        enabled_streaming_sources + transcript
      end
    end

    def previewable_element
      thumb_url = stacks_square_url(@druid, file.title, size: '75')
      render MediaWrapperComponent.new(thumbnail: thumb_url, file:, type:, file_index: @resource_iteration.index,
                                       scroll: true) do
        tag.img(src: stacks_thumb_url(@druid, file.title),
                class: 'sul-embed-media-thumb')
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
    def transcript
      return unless render_captions?

      # A video clip may have multiple caption files in different languages.
      # We want to enable the user to select from any of these options.
      # We also want the different language options to be listed alphabetically.
      safe_join(
        sort_caption_tracks(@resource.caption_files).map do |caption_file|
          lang_code = caption_file.language || 'en'
          lang_label = caption_language(lang_code)
          tag.track(src: caption_file.file_url, kind: 'captions', srclang: lang_code, label: lang_label)
        end
      )
    end

    # Sort the caption files by language label so we can display them in alphabetical order in the
    # captions options list.
    def sort_caption_tracks(caption_files)
      caption_files.sort_by { |cfile| caption_language(cfile.language) }
    end

    def caption_language(language_code)
      FILE_LANGUAGE_CAPTION_LABELS.fetch(language_code, 'Caption')
    end

    def render_captions?
      @include_transcripts && @resource.caption_files
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
