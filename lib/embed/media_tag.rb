module Embed
  # Utility class to handle generating HTML media tags
  class MediaTag
    SUPORTED_MEDIA_TYPES = [:audio, :video].freeze
    ENABLED_STREAMING_TYPES = [:hls].freeze
    STREAMING_URL_SCHEMA = {
      hls: { protocol: 'http', suffix: 'playlist.m3u8' },
      mdash: { protocol: 'http', suffix: 'manifest.mpd' }
    }.freeze

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
        next unless SUPORTED_MEDIA_TYPES.include?(resource.type.to_sym)
        resource.files.each do |file|
          ng_document.send(resource.type.to_sym, controls: 'controls', height: "#{viewer.body_height}px") do
            enabled_streaming_sources(file)
          end
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
      protocol = STREAMING_URL_SCHEMA[type][:protocol]
      suffix = STREAMING_URL_SCHEMA[type][:suffix]
      "#{protocol}://#{streaming_base_url}/#{streaming_url_file_segment(file)}/#{suffix}"
    end

    def streaming_url_file_segment(file)
      "#{::File.extname(file.title).delete('.')}:#{file.title}"
    end

    def streaming_base_url
      "#{streaming_config.host}:#{streaming_config.port}/#{streaming_config.application}"
    end

    def streaming_config
      Settings.streaming_service
    end
  end
end
