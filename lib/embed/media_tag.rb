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
      purl_document.contents.each do |resource|
        next unless primary_file?(resource)
        label = resource.description
        resource.files.each do |file|
          label = file.title if label.blank?
          output << if SUPPORTED_MEDIA_TYPES.include?(resource.type.to_sym)
                      media_element(label, file, resource.type)
                    else
                      previewable_element(label, file)
                    end
          @file_index += 1
        end
      end
      output
    end

    private

    attr_reader :purl_document, :request, :viewer

    def media_element(label, file, type)
      media_wrapper(label: label, stanford_only: file.stanford_only?, location_restricted: file.location_restricted?) do
        <<-HTML.strip_heredoc
          <#{type}
            id="sul-embed-media-#{file_index}"
            data-src="#{streaming_url_for(file, :dash)}"
            data-auth-url="#{authentication_url(file)}"
            controls='controls'
            class="#{'sul-embed-many-media' if many_primary_files?}"
            #{media_element_height_attr(file)}
            #{media_element_width_attr(file)}
            data-height="#{media_element_height(file)}"
            data-width="#{media_element_width(file)}"
            data-viewer-body-height="#{viewer.body_height}"
            data-usable-body-height="#{usable_body_height}">
            #{enabled_streaming_sources(file)}
          </#{type}>
        HTML
      end
    end

    def previewable_element(label, file)
      media_wrapper(label: label, thumbnail: stacks_square_url(@purl_document.druid, file.title, size: '75')) do
        "<img
          src='#{stacks_thumb_url(@purl_document.druid, file.title)}'
          class='sul-embed-media-thumb #{'sul-embed-many-media' if many_primary_files?}'
          style='max-height: #{media_element_height(file)}px'
        />"
      end
    end

    def media_wrapper(label:, thumbnail: '', stanford_only: nil, location_restricted: nil, &block)
      <<-HTML.strip_heredoc
        <div data-stanford-only="#{stanford_only}"
             data-location-restricted="#{location_restricted}"
             data-file-label="#{label}"
             data-slider-object="#{file_index}"
             data-thumbnail-url="#{thumbnail}">
          <div class='sul-embed-media-wrapper'>
            #{access_restricted_overlay(stanford_only, location_restricted)}
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

    def usable_body_height
      many_primary_files? ? viewer.body_height.to_i - MEDIA_INDEX_CONTROL_HEIGHT : viewer.body_height.to_i
    end

    def media_element_height(file)
      return usable_body_height unless file.video_height && (file.video_height.to_i < usable_body_height)
      file.video_height.to_i
    end

    def media_element_width(file)
      return unless file.video_width

      # if there's a width specified, scale it by the same factor as the actual
      # display height vs the specified height, so correct aspect ratio is maintained
      height_scale_factor = media_element_height(file) / file.video_height.to_d
      (file.video_width.to_i * height_scale_factor).to_i
    end

    def media_element_height_attr(file)
      %(height="#{media_element_height(file)}px") if media_element_height(file)
    end

    def media_element_width_attr(file)
      %(width="#{media_element_width(file)}px") if media_element_width(file)
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
      # jvine says the -container div is necessary to style the elements so that
      # sul-embed-media-access-restricted positions correctly
      # TODO: line1 and line1 spans should be populated by values returned from stacks
      <<-HTML.strip_heredoc
        #{location_only_overlay(stanford_only, location_restricted)}
        <div class='sul-embed-media-access-restricted-container' data-access-restricted-message>
          <div class='sul-embed-media-access-restricted'>
            #{access_restricted_message(stanford_only, location_restricted)}
          </div>
        </div>
      HTML
    end

    def location_only_overlay(stanford_only, location_restricted)
      return unless location_restricted && !stanford_only
      <<-HTML.strip_heredoc
        <i class="sul-i-file-video-3 sul-embed-media-location-only-restricted-overlay" data-location-restricted-overlay></i>
      HTML
    end

    def streaming_settings_for(type)
      Settings.streaming[type] || {}
    end

    def enabled_streaming_types
      Settings.streaming[:source_types]
    end

    def file_index
      @file_index ||= 0
    end

    def streaming_url_for(file, type)
      stacks_media_stream = Embed::StacksMediaStream.new(druid: purl_document.druid, file_name: file.title)
      case type.to_sym
      when :hls
        stacks_media_stream.to_playlist_url
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
