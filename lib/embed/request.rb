# frozen_string_literal: true

module Embed
  class Request
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def url
      params[:url]
    end

    def format
      params[:format] || 'json'
    end

    def maxheight
      height = params[:maxheight].to_i
      height unless height.zero?
    end

    def maxwidth
      width = params[:maxwidth].to_i
      width unless width.zero?
    end

    # This is to support a legacy use
    # case where a consumer was applying
    # styles to the viewer output to
    # achieve a full screen display
    def fullheight?
      params[:fullheight] == 'true'
    end

    def hide_title?
      params[:hide_title] == 'true'
    end

    def hide_embed_this?
      params[:hide_embed] == 'true'
    end

    def hide_download?
      params[:hide_download] == 'true'
    end

    def hide_search?
      params[:hide_search] == 'true'
    end

    def min_files_to_search
      params[:min_files_to_search]
    end

    def object_druid
      url_path_segments[0]
    end

    def object_version_id
      url_path_segments[2]
    end

    def url_path_segments
      URI.parse(url).path.split('/').compact_blank
    end

    # @return [Embed::Purl]
    def purl_object
      @purl_object ||= Purl.find(object_druid, object_version_id)
    end

    def as_url_params
      p = params.slice(
        :hide_title, :hide_embed, :hide_search, :hide_download,
        :min_files_to_search,
        :canvas_id, :canvas_index,
        :search, :suggested_search,
        :image_tools,
        :workspace_state
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

    def workspace_state
      params[:workspace_state]
    end

    def image_tools
      params[:image_tools]
    end

    def validate!(url_parameter: true, url_scheme: true, format: true)
      require_url_parameter if url_parameter
      validate_url_scheme if url_scheme
      validate_format if format
    end

    def cdl_hold_record_id
      params[:cdl_hold_record_id]
    end

    private

    def require_url_parameter
      raise NoURLProvided if url.blank?
    end

    def validate_url_scheme
      raise InvalidURLScheme unless url_scheme_is_valid?
    end

    def url_scheme_is_valid?
      uri = URI.parse(url)
      uri.is_a?(URI::HTTP) && # true for http or https
        uri.hostname == URI.parse(Settings.purl_url).hostname &&
        uri.path.size > 1 # one would just be the root path (e.g. "/")
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
