# frozen_string_literal: true

module Embed
  class ViewerFactory
    delegate :height, :width, to: :viewer
    def initialize(request)
      @request = request
      raise Embed::PURL::ResourceNotEmbeddable unless request.purl_object.valid?
    end

    def viewer
      @viewer ||= registered_or_default_viewer.new(@request)
    end

    private

    def registered_or_default_viewer
      registered_viewer(type: object_type) || default_viewer
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
