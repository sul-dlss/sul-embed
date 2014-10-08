module Embed
  class Request
    include URLSchemes
    attr_reader :params
    def initialize(params)
      @params = params
      validate
    end

    def url
      params[:url]
    end

    def format
      params[:format] || 'json'
    end

    def maxheight
      params[:maxheight]
    end

    def maxwidth
      params[:maxwidth]
    end

    def object_druid
      url[/\w*$/]
    end

    def purl_object
      @purl_object ||= PURL.new(object_druid)
    end

    private
    def validate
      require_url_parameter
      validate_url_scheme
    end
    def require_url_parameter
      raise NoURLProvided unless url.present?
    end
    def validate_url_scheme
      raise InvalidURLScheme unless url_scheme_is_valid?
    end
    def url_scheme_is_valid?
      url_schemes.any? do |scheme|
        url =~ scheme
      end
    end
    class NoURLProvided < StandardError
      def initialize(msg="You must provide a URL parameter")
        super
      end
    end
    class InvalidURLScheme < StandardError
      def initialize(msg="The provided URL is not a supported scheme for this embed service")
        super
      end
    end
  end
end
