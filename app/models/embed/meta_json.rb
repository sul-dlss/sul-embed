# frozen_string_literal: true

module Embed
  class MetaJson
    def initialize(purl_object:)
      @druid = purl_object.druid
      @version_id = purl_object.version_id
    end

    def json
      @json ||= JSON.parse(response)
    end

    def searchworks?
      json['searchworks']
    end

    def earthworks?
      json['earthworks']
    end

    def http_response
      @http_response ||= begin
        conn = Faraday.new(url: meta_json_url)

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

    def meta_json_url
      return "#{Settings.purl_url}/#{@druid}.meta_json" if @version_id.blank?

      "#{Settings.purl_url}/#{@druid}/version/#{@version_id}.meta_json"
    end
  end
end
