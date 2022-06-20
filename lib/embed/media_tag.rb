# frozen_string_literal: true

module Embed
  # Utility class to handle generating HTML <video> and <audio> tags
  # Currently, MPEG-DASH is used at the <video> element level (in a data attribute to be picked up by javascript)
  # and HLS is used as a <source> within the <video> or <audio> tag.
  class MediaTag
    SUPPORTED_MEDIA_TYPES = %i[audio video].freeze

    include Embed::StacksImage

    attr_accessor :file_index

    def initialize(viewer)
      @viewer = viewer
      @purl_document = viewer.purl_object
      @file_index = 0
    end

    def to_html
      output = []
      purl_document.contents.each do |resource|
        next if resource.primary_file.blank?

        output << if SUPPORTED_MEDIA_TYPES.include?(resource.type.to_sym)
                    media_element(resource.primary_file, resource.type)
                  else
                    previewable_element(resource.primary_file)
                  end
        self.file_index += 1
      end
      output.join
    end

    private

    attr_reader :purl_document, :request, :viewer

    def media_element(file, type)
      file_thumb = stacks_square_url(@purl_document.druid, file.thumbnail.title, size: '75') if file.thumbnail
      media_wrapper(thumbnail: file_thumb, file: file) do
        <<~HTML
          #{access_restricted_overlay(file.try(:stanford_only?), file.try(:location_restricted?))}
          <#{type}
            id="sul-embed-media-#{file_index}"
            data-src="#{streaming_url_for(file, :dash)}"
            data-auth-url="#{authentication_url(file)}"
            #{poster_attribute(file)}
            controls='controls'
            aria-labelledby="access-restricted-message-div-#{file_index}"
            class="sul-embed-media-file #{'sul-embed-many-media' if many_primary_files?}"
            height="100%">
            #{enabled_streaming_sources(file)}
          </#{type}>
        HTML
      end
    end

    def previewable_element(file)
      thumb_url = stacks_square_url(@purl_document.druid, file.title, size: '75')
      media_wrapper(thumbnail: thumb_url, file: file, scroll: true) do
        "<img
          src='#{stacks_thumb_url(@purl_document.druid, file.title)}'
          class='sul-embed-media-thumb #{'sul-embed-many-media' if many_primary_files?}'
        />"
      end
    end

    def media_wrapper(thumbnail: '', file: nil, scroll: false, &block)
      <<~HTML
        <div style="flex: 1 0 100%;#{' overflow-y: scroll' if scroll}"
             data-stanford-only="#{file.try(:stanford_only?)}"
             data-location-restricted="#{file.try(:location_restricted?)}"
             data-file-label="#{file.label}"
             data-slider-object="#{file_index}"
             data-thumbnail-url="#{thumbnail}"
             data-duration="#{file.try(:duration)}">
          <div class='sul-embed-media-wrapper'>
            #{yield(block) if block}
          </div>
        </div>
      HTML
    end

    def enabled_streaming_sources(file)
      enabled_streaming_types.map do |streaming_type|
        "<source
           src='#{streaming_url_for(file, streaming_type)}'
           type='#{streaming_settings_for(streaming_type)[:mimetype]}'>
        </source>"
      end.join
    end

    def many_primary_files?
      primary_files_count > 1
    end

    def primary_files_count
      purl_document.contents.count do |resource|
        resource.primary_file.present?
      end
    end

    def poster_attribute(file)
      return unless file.thumbnail

      thumb_url = if file.thumbnail.world_downloadable?
                    stacks_thumb_url(@purl_document.druid, file.thumbnail.title, size: '!800,600')
                  else
                    stacks_thumb_url(@purl_document.druid, file.thumbnail.title)
                  end

      "poster='#{thumb_url}'"
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
      return unless stanford_only || location_restricted

      # TODO: line1 and line1 spans should be populated by values returned from stacks
      <<~HTML
        <div class='sul-embed-media-access-restricted-container' data-access-restricted-message>
          <div class='sul-embed-media-access-restricted' id="access-restricted-message-div-#{file_index}">
            #{access_restricted_message(stanford_only, location_restricted)}
          </div>
        </div>
      HTML
    end

    def streaming_settings_for(type)
      Settings.streaming[type] || {}
    end

    def enabled_streaming_types
      Settings.streaming[:source_types]
    end

    def streaming_url_for(file, type)
      stacks_media_stream = Embed::StacksMediaStream.new(druid: purl_document.druid, file_name: file.title)
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
      attributes = { host: Settings.stacks_url, druid: purl_document.druid, title: file.title }
      Settings.streaming.auth_url % attributes
    end
  end
end
