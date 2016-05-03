module Embed
  # Utility class to handle generating HTML <video> and <audio> tags
  # Currently, MPEG-DASH is used at the <video> element level (in a data attribute to be picked up by javascript)
  # and HLS is used as a <source> within the <video> or <audio> tag.
  class MediaTag
    SUPPORTED_MEDIA_TYPES = [:audio, :video].freeze

    def initialize(ng_doc, viewer)
      @ng_document = ng_doc
      @viewer = viewer
      @purl_document = viewer.purl_object
      build_markup
    end

    private

    attr_reader :ng_document, :purl_document, :request, :viewer

    def build_markup
      purl_document.contents.each do |resource|
        next unless SUPPORTED_MEDIA_TYPES.include?(resource.type.to_sym)
        label = resource.description
        resource.files.each do |file|
          label = file.title if label.blank?
          ng_document.send(
            resource.type.to_sym,
            'data-file-label': label,
            'data-slider-object': file_index,
            'data-src': streaming_url_for(file, :dash),
            controls: 'controls',
            height: "#{viewer.body_height.to_i - 24}px"
          ) { enabled_streaming_sources(file) }
          @file_index += 1
        end
      end
    end

    def enabled_streaming_sources(file)
      enabled_streaming_types.each do |streaming_type|
        ng_document.source(
          src: streaming_url_for(file, streaming_type),
          type: streaming_settings_for(streaming_type)[:mimetype]
        )
      end
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
      "#{Settings.stacks_url}/media/#{purl_document.druid}/#{file.title}/stream#{suffix}"
    end
  end
end
