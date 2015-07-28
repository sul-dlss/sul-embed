module Embed
  class Viewer
    require 'embed/viewer/common_viewer'
    # Auto-require all .rb files in the viewer directory
    Dir[File.join(File.dirname(__FILE__), 'viewer', '*.rb')].each {|file| require file }
    
    delegate :height, :width, to: :viewer
    def initialize(request)
      @request = request
      raise Embed::PURL::ResourceNotEmbeddable unless request.purl_object.type.present?
    end
    def viewer
      @viewer ||= registered_or_default_viewer.new(@request)
    end
    private
    def registered_or_default_viewer
      registered_viewer || default_viewer
    end
    def default_viewer
      @default_viewer ||= Embed.registered_viewers.detect do |viewer_class|
        viewer_class.respond_to?(:default_viewer?) && viewer_class.default_viewer?
      end
    end
    def registered_viewer
      @registered_type ||= Embed.registered_viewers.detect do |type_class|
        type_class.supported_types.include?(@request.purl_object.type.to_sym)
      end
    end
  end
end
