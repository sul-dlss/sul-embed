# frozen_string_literal: true

module Embed
  class Request
    include URLSchemes
    attr_reader :params, :rails_request
    def initialize(params, rails_request = nil)
      @params = params
      @rails_request = rails_request
    end

    def url
      params[:url]
    end

    def format
      params[:format] || 'json'
    end

    def maxheight
      return if params[:maxheight].to_i.zero?

      params[:maxheight].to_i
    end

    def maxwidth
      return if params[:maxwidth].to_i.zero?

      params[:maxwidth].to_i
    end

    # This is to support a legacy use
    # case where a consumer was applying
    # styles to the viewer output to
    # achieve a full screen display
    def fullheight?
      params[:fullheight] == 'true'
    end

    def hide_title?
      params[:hide_title] && params[:hide_title] == 'true'
    end

    def hide_embed_this?
      params[:hide_embed] && params[:hide_embed] == 'true'
    end

    def hide_download?
      params[:hide_download] && params[:hide_download] == 'true'
    end

    def hide_search?
      params[:hide_search] && params[:hide_search] == 'true'
    end

    def min_files_to_search
      params[:min_files_to_search]
    end

    def object_druid
      url[/\w*$/]
    end

    def purl_object
      @purl_object ||= PURL.new(object_druid)
    end

    def as_url_params
      p = params.slice(
        :hide_title, :hide_embed, :hide_search, :hide_download,
        :min_files_to_search,
        :canvas_id, :canvas_index,
        :search, :image_tools
      )

      if p.respond_to? :permit!
        p.permit!
      else
        p
      end
    end

    def canvas_id
      params[:canvas_id]
    end

    def canvas_index
      params[:canvas_index]
    end

    def search
      params[:search]
    end

    def suggested_search
      params[:suggested_search]
    end

    def image_tools
      params[:image_tools]
    end

    def validate!(url_parameter: true, url_scheme: true, format: true)
      require_url_parameter if url_parameter
      validate_url_scheme if url_scheme
      validate_format if format
    end

    private

    def require_url_parameter
      raise NoURLProvided if url.blank?
    end

    def validate_url_scheme
      raise InvalidURLScheme unless url_scheme_is_valid?
    end

    def url_scheme_is_valid?
      url_schemes.any? do |scheme|
        url =~ scheme
      end && url =~ %r{/\w+$}
    end

    def validate_format
      raise InvalidFormat unless format_is_valid?
    end

    def format_is_valid?
      [/^json$/, /^xml$/].any? do |supported_format|
        format =~ supported_format
      end
    end
    class NoURLProvided < StandardError
      def initialize(msg = 'You must provide a URL parameter')
        super
      end
    end
    class InvalidURLScheme < StandardError
      def initialize(msg = 'The provided URL is not a supported scheme for this embed service')
        super
      end
    end
    class InvalidFormat < StandardError
      def initialize(msg = 'The provided format is not supported for this embed service')
        super
      end
    end
  end
end
