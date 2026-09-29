# frozen_string_literal: true

module Embed
  class PurlClient
    attr_reader :url

    def initialize(url:)
      @url = url
    end

    def response
      @response ||= ensure_success(request)
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError
      raise Purl::ResourceNotAvailable, "Resource unavailable #{url} (connection error)"
    end

    private

    def connection
      @connection ||= Faraday.new(url:)
    end

    def request
      connection.get do |request|
        request.options.timeout = Settings.purl_read_timeout
        request.options.open_timeout = Settings.purl_conn_timeout
      end
    end

    def ensure_success(response)
      return response if response.success?

      raise Purl::ResourceNotAvailable, "Resource unavailable #{url} (status: #{response.status})"
    end
  end
end
