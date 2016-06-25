module Embed
  # Utility class to handle generating HTML <video> and <audio> tags
  # Currently, MPEG-DASH is used at the <video> element level (in a data attribute to be picked up by javascript)
  # and HLS is used as a <source> within the <video> or <audio> tag.
  class MediaTag
    SUPPORTED_MEDIA_TYPES = [:audio, :video].freeze
    MEDIA_INDEX_CONTROL_HEIGHT = 24

    def initialize(viewer)
      @viewer = viewer
      @purl_document = viewer.purl_object
    end

    def to_html
      output = ''
      purl_document.contents.each do |resource|
        next unless SUPPORTED_MEDIA_TYPES.include?(resource.type.to_sym)
        label = resource.description
        resource.files.each do |file|
          label = file.title if label.blank?
          output << media_element(label, file, resource.type)
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
            data-src="#{streaming_url_for(file, :dash)}"
            data-auth-url="#{authentication_url(file)}"
            controls='controls'
            class="#{'sul-embed-many-media' if many_media?}"
            height="#{media_element_height}">
            #{enabled_streaming_sources(file)}
          </#{type}>
        HTML
      end
    end

    def media_wrapper(label:, stanford_only:, location_restricted:, &block)
      <<-HTML.strip_heredoc
        <div data-stanford-only="#{stanford_only}" data-location-restricted="#{location_restricted}" data-file-label="#{label}" data-slider-object="#{file_index}">
          <div class='sul-embed-media-wrapper'>
            #{access_restricted_message(stanford_only, location_restricted)}
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

    def media_element_height
      return "#{viewer.body_height}px" unless many_media?
      "#{viewer.body_height.to_i - MEDIA_INDEX_CONTROL_HEIGHT}px"
    end

    def many_media?
      media_files_count > 1
    end

    def media_files_count
      purl_document.contents.count do |resource|
        SUPPORTED_MEDIA_TYPES.include?(resource.type.to_sym)
      end
    end

    def access_restricted_message(stanford_only, location_restricted)
      return unless stanford_only || location_restricted
      # jvine says the -container div is necessary to style the elements so that
      # sul-embed-media-access-restricted positions correctly
      # TODO: line1 and line1 spans should be populated by values returned from stacks
      <<-HTML.strip_heredoc
        #{location_only_overlay(stanford_only, location_restricted)}
        <div class='sul-embed-media-access-restricted-container' data-access-restricted-message>
          <div class='sul-embed-media-access-restricted'>
            <span class='line1'>Limited access for non-Stanford guests</span>
            <span class='line2'>See Access conditions for more information.</span>
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
      suffix = streaming_settings_for(type)[:suffix]
      "#{stacks_base_url(file)}/stream#{suffix}"
    end

    def authentication_url(file)
      "#{stacks_base_url(file)}/auth_check"
    end

    def stacks_base_url(file)
      "#{Settings.stacks_url}/media/#{purl_document.druid}/#{file.title}"
    end
  end
end
