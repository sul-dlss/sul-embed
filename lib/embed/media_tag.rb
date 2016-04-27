module Embed
  # Utility class to handle generating HTML media tags
  class MediaTag
    SUPPORTED_MEDIA_TYPES = [:audio, :video].freeze
    # ENABLED_STREAMING_TYPES may go away once we implement dash,
    # and we may just handle contructing the URLs directly in the markup
    # where necessary.
    ENABLED_STREAMING_TYPES = [:hls].freeze

    def initialize(ng_doc, viewer)
      @ng_document = ng_doc
      @viewer = viewer
      @purl_document = viewer.purl_object
      build_markup
    end

    private

    attr_reader :ng_document, :purl_document, :request, :viewer

    def build_markup
      file_index = 0
      purl_document.contents.each do |resource|
        label = resource.description
        next unless SUPPORTED_MEDIA_TYPES.include?(resource.type.to_sym)
        resource.files.each do |file|
          label = file.title if label.blank?
          ng_document.send(
            resource.type.to_sym,
            'data-file-label': label,
            'data-slider-object': file_index,
            'data-src': streaming_url_for(file, :dash),
            controls: 'controls',
            height: "#{viewer.body_height.to_i - 24}px"
          ) do
            enabled_streaming_sources(file)
          end
          file_index += 1
        end
      end
    end

    def enabled_streaming_sources(file)
      ENABLED_STREAMING_TYPES.each do |streaming_type|
        ng_document.source(
          src: streaming_url_for(file, streaming_type),
          type: file.mimetype
        )
      end
    end

    def streaming_url_for(file, type)
      suffix = Settings.streaming_url_suffixes[type]
      "#{Settings.stacks_url}/media/#{purl_document.druid}/#{file.title}/stream#{suffix}"
    end
  end
end
