module Embed
  # Utility class to handle generating HTML <video> and <audio> tags
  # Currently, MPEG-DASH is used at the <video> element level (in a data attribute to be picked up by javascript)
  # and HLS is used as a <source> within the <video> or <audio> tag.
  class MediaTag
    SUPPORTED_MEDIA_TYPES = [:audio, :video].freeze
    MEDIA_INDEX_CONTROL_HEIGHT = 24

    include Embed::StacksImage

    def initialize(viewer)
      @viewer = viewer
      @purl_document = viewer.purl_object
    end

    def to_html
      output = ''
      file_index = 0
      purl_document.contents.select { |resource| primary_file?(resource) }.each do |resource|
        output << output_for_resource(resource, file_index)
        file_index += 1
      end
      output
    end

    private

    attr_reader :purl_document, :request, :viewer

    def output_for_resource(resource, file_index)
      label = resource.description
      if resource.media_file
        label = resource.media_file.title if label.blank?
        media_element(label, resource, file_index)
      elsif resource.media_thumb
        label = resource.media_thumb.title if label.blank?
        previewable_element(label, resource.media_thumb, file_index)
      else
        ''
      end
    end

    def media_element(label, resource, file_index)
      thumbnail = stacks_square_url(purl_document.druid, resource.media_thumb.title, size: '75') if resource.media_thumb
      media_wrapper(label: label, file: resource.media_file, thumbnail: thumbnail, file_index: file_index) do
        <<-HTML.strip_heredoc
          <#{resource.type}
            id="sul-embed-media-#{file_index}"
            data-src="#{streaming_url_for(resource.media_file, :dash)}"
            data-auth-url="#{authentication_url(resource.media_file)}"
            controls='controls'
            aria-labelledby="access-restricted-message-div-#{file_index}"
            class="#{'sul-embed-many-media' if many_primary_files?}"
            style="height: #{media_element_height}; display:none;"
            #{poster_attr_html(resource.media_thumb)}
            height="#{media_element_height}">
            #{enabled_streaming_sources(resource.media_file)}
          </#{resource.type}>
        HTML
      end
    end

    def previewable_element(label, file, file_index)
      media_wrapper(label: label, thumbnail: stacks_square_url(purl_document.druid, file.title, size: '75'), file_index: file_index) do
        "<img
          src='#{stacks_thumb_url(purl_document.druid, file.title)}'
          class='sul-embed-media-thumb #{'sul-embed-many-media' if many_primary_files?}'
          style='max-height: #{media_element_height}'
        />"
      end
    end

    def media_wrapper(label:, thumbnail: '', file: nil, file_index: nil, &block)
      <<-HTML.strip_heredoc
        <div data-stanford-only="#{file.try(:stanford_only?)}"
             data-location-restricted="#{file.try(:location_restricted?)}"
             data-file-label="#{label}"
             data-slider-object="#{file_index}"
             data-thumbnail-url="#{thumbnail}"
             data-duration="#{file.try(:video_duration).try(:to_s)}">
          <div class='sul-embed-media-wrapper'>
            #{access_restricted_overlay(file.try(:stanford_only?), file.try(:location_restricted?))}
            #{yield(block) if block_given?}
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

    def poster_attr_html(file)
      "poster='#{stacks_thumb_url(purl_document.druid, file.title)}'" if file
    end

    def media_element_height
      return "#{viewer.body_height}px" unless many_primary_files?
      "#{viewer.body_height.to_i - MEDIA_INDEX_CONTROL_HEIGHT}px"
    end

    def many_primary_files?
      primary_files_count > 1
    end

    def primary_files_count
      purl_document.contents.count do |resource|
        primary_file?(resource)
      end
    end

    def primary_file?(resource)
      SUPPORTED_MEDIA_TYPES.include?(resource.type.to_sym) || resource.files.any?(&:previewable?)
    end

    def access_restricted_message(stanford_only, location_restricted)
      if location_restricted && !stanford_only
        <<-HTML.strip_heredoc
          <span class='line1'>Restricted media cannot be played in your location.</span>
          <span class='line2'>See Access conditions for more information.</span>
        HTML
      else
        <<-HTML.strip_heredoc
          <span class='line1'>Limited access for<br>non-Stanford guests.</span>
          <span class='line2'>See Access conditions for more information.</span>
        HTML
      end
    end

    def access_restricted_overlay(stanford_only, location_restricted)
      return unless stanford_only || location_restricted
      # TODO: line1 and line1 spans should be populated by values returned from stacks
      <<-HTML.strip_heredoc
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
      "#{stacks_base_url(file)}/auth_check"
    end

    def stacks_base_url(file)
      "#{Settings.stacks_url}/media/#{purl_document.druid}/#{file.title}"
    end
  end
end
