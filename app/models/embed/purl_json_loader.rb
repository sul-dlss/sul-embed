# frozen_string_literal: true

module Embed
  class PurlJsonLoader # rubocop:disable Metrics/ClassLength
    LEGACY_TYPE_MAP = {
      'object' => 'file'
    }.freeze

    def initialize(druid, version_id = nil)
      @druid = druid
      @version_id = version_id
    end

    def load # rubocop:disable Metrics/MethodLength
      {
        druid: @druid,
        version_id: @version_id,
        type:,
        title:,
        contents:,
        collections:,
        copyright:,
        license:,
        use_and_reproduction:,
        embargo_release_date:,
        bounding_box:,
        archived_site_url:,
        embargoed:,
        stanford_only_unrestricted:,
        controlled_digital_lending:,
        public:
      }
    end

    def etag
      http_response&.headers&.fetch('ETag', nil)
    end

    def last_modified
      header = http_response&.headers&.fetch('Last-Modified', nil)
      return unless header

      Time.rfc2822(header)
    end

    private

    def embargoed
      json.dig('access', 'embargo').present?
    end

    def stanford_only_unrestricted
      json.dig('access', 'download') == 'stanford'
    end

    def controlled_digital_lending
      json.dig('access', 'controlledDigitalLending')
    end

    def public
      json.dig('access', 'download') == 'world'
    end

    def archived_site_url
      Array(json.dig('description', 'access', 'url')).find do |url|
        url['displayLabel'] == 'Archived website'
      end&.fetch('value')
    end

    def collections
      Array(json.dig('structural', 'isMemberOf')).map { |id| id.delete_prefix('druid:') }
    end

    def bounding_box
      subjects = Array(json.dig('description', 'geographic')).flat_map do |geo|
        geo['subject']
      end
      box_coords = subjects.find { |subj| subj['type'] == 'bounding box coordinates' }
      return unless box_coords

      points = box_coords['structuredValue']
      [[find_point(points, 'south'), find_point(points, 'west')],
       [find_point(points, 'north'), find_point(points, 'east')]]
    end

    def find_point(points, direction)
      points.find { |point| point['type'] == direction }&.fetch('value')
    end

    def embargo_release_date
      json.dig('access', 'embargo', 'releaseDate')&.sub(/T.*/, '') # Trim the time off the end.
    end

    def contents
      # NOTE: collections don't have structural
      return [] unless json['structural']

      Array(json.dig('structural', 'contains')).map do |file_set_json|
        Purl::ResourceJsonDeserializer.new(@druid, file_set_json).deserialize
      end + external_resources(Array(json.dig('structural', 'hasMemberOrders', 0, 'members')))
    end

    def external_resources(identifiers)
      identifiers.map do |identifier|
        druid = identifier.delete_prefix('druid:')
        component = Embed::Purl.find(druid)
        Purl::Resource.new(
          druid:,
          type: component.type,
          description: component.title,
          files: []
        )
      end
    end

    def license
      license_uri = json.dig('access', 'license')
      return unless license_uri

      Rails.application.config_for(:licenses, env: 'production').dig(license_uri, :description)
    end

    def type
      cocina_type = json.fetch('type').delete_prefix('https://cocina.sul.stanford.edu/models/')
      LEGACY_TYPE_MAP.fetch(cocina_type, cocina_type)
    end

    def title
      json.fetch('label')
    end

    def use_and_reproduction
      json.dig('access', 'useAndReproductionStatement')
    end

    def copyright
      json.dig('access', 'copyright')
    end

    def json
      @json ||= JSON.parse(response)
    end

    def purl_json_url
      return "#{Settings.purl_url}/#{@druid}.json" if @version_id.blank?

      "#{Settings.purl_url}/#{@druid}/version/#{@version_id}.json"
    end

    def http_response
      @http_response ||= begin
        conn = Faraday.new(url: purl_json_url)

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
