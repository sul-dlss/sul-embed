# frozen_string_literal: true

module Embed
  class ViewerFactory
    # @param [Embed::Request] request
    def initialize(embed_request)
      @embed_request = embed_request
      raise Embed::Purl::ResourceNotEmbeddable unless embed_request.purl_object.valid?
    end

    def viewer
      @viewer ||= viewer_class.new(@embed_request)
    end

    private

    def iiif_annotations?
      @embed_request.purl_object.iiif_annotations?
    end

    def viewer_class # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
      case @embed_request.purl_object.type
      when 'file'
        Embed::Viewer::File
      when 'geo'
        Embed::Viewer::Geo
      when 'map'
        if iiif_annotations?
          Embed::Viewer::Geo
        else
          Embed::Viewer::MiradorViewer
        end
      when 'image', 'manuscript', 'book'
        Embed::Viewer::MiradorViewer
      when 'document'
        Embed::Viewer::DocumentViewer
      when '3d'
        Embed::Viewer::ModelViewer
      when 'media'
        Settings.enable_media_viewer? ? Embed::Viewer::Media : Embed::Viewer::File
      when 'webarchive-seed'
        Embed::Viewer::WasSeed
      end
    end
  end
end
