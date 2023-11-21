# frozen_string_literal: true

module Embed
  class ViewerFactory
    delegate :height, :width, to: :viewer
    def initialize(request)
      @request = request
      raise Embed::Purl::ResourceNotEmbeddable unless request.purl_object.valid?
    end

    def viewer
      @viewer ||= viewer_class.new(@request)
    end

    private

    def viewer_class # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
      case @request.purl_object.type
      when 'file'
        Embed::Viewer::File
      when 'geo'
        Embed::Viewer::Geo
      when 'image', 'manuscript', 'map', 'book'
        Embed::Viewer::M3Viewer
      when 'document'
        Embed::Viewer::PdfViewer
      when '3d'
        Embed::Viewer::Virtex3dViewer
      when 'media'
        Settings.enable_media_viewer? ? Embed::Viewer::Media : Embed::Viewer::File
      when 'webarchive-seed'
        Embed::Viewer::WasSeed
      end
    end

    # @return [Symbol] the type of object to display
    def object_type
      @request.purl_object.type.to_sym
    end

    def default_viewer
      Embed::Viewer::File
    end

    def registered_viewer(type:)
      @registered_viewer ||= Embed.registered_viewers.detect do |type_class|
        type_class.supported_types.include?(type)
      end
    end
  end
end
