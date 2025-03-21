# frozen_string_literal: true

module Embed
  class Response
    def initialize(url:)
      @url = url
    end

    attr_reader :url

    def json
      JSON.parse(response)
    end

    def etag
      response.etag
      http_response&.headers&.fetch('ETag', nil)
    end

    def last_modified
      response.last_modified
      header = http_response&.headers&.fetch('Last-Modified', nil)
      return unless header

      Time.rfc2822(header)
    end

    def http_response
      @http_response ||= begin
        conn = Faraday.new(url:)

        conn.get do |request|
          request.options.timeout = Settings.purl_read_timeout
          request.options.open_timeout = Settings.purl_conn_timeout
        end
      end
    end

    def response
      @response ||=
        begin
          unless http_response.success?
            raise Purl::ResourceNotAvailable,
                  "Resource unavailable #{purl_json_url} (status: #{http_response.status})"
          end

          http_response.body
        end
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError
      raise Purl::ResourceNotAvailable, "Resource unavailable #{purl_json_url} (connection error)"
    end
  end
end
