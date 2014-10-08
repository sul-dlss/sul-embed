module Embed
  class Viewer
    require 'embed/viewer/file'
    delegate :height, :width, to: :viewer
    def initialize(request)
      @request = request
    end
    def viewer
      @viewer ||= registered_or_default_viewer.new(@request)
    end
    private
    def registered_or_default_viewer
      registered_viewer || default_viewer
    end
    def default_viewer
      @default_viewer ||= Embed.registered_viewers.find do |viewer_class|
        viewer_class.respond_to?(:default_viewer?) && viewer_class.default_viewer?
      end
    end
    def registered_viewer
      @registered_type ||= Embed.registered_viewers.find do |type_class|
        type_class.supported_types.include?(@request.purl_object.type.to_sym)
      end
    end
  end
end
