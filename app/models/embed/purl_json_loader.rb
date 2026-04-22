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

    def load # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      {
        druid: @druid,
        version_id: @version_id,
        type:,
        title:,
        contents:,
        constituents:, # identifiers for virtual object members
        collections:,
        copyright:,
        license:,
        use_and_reproduction:,
        embargo_release_date:,
        bounding_box:,
        layer_type:,
        archived_site_url:,
        embargoed:,
        location_restriction:,
        restricted_location:,
        download:,
        view:,
        controlled_digital_lending:
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

    def embargoed # rubocop:disable Naming/PredicateMethod
      json.dig('access', 'embargo').present?
    end

    def location_restriction
      return 'download' if json.dig('access', 'download') == 'location-based'
      return 'view' if json.dig('access', 'view') == 'location-based'

      false
    end

    def restricted_location
      return unless location_restriction

      locations = Settings.locations
      locations[json.dig('access', 'location')] || locations[:fallback]
    end

    def download
      json.dig('access', 'download')
    end

    def view
      json.dig('access', 'view')
    end

    def controlled_digital_lending
      json.dig('access', 'controlledDigitalLending')
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
      cocina_record.coordinates_as_bbox.first
    end

    # Decode the value of geographic form with "type: 'type'", into a MapLibre layer type.
    # Expected values are:
    #   Dataset#Polygon: Polygon data
    #   Dataset#Raster: Raster data
    #   Dataset#Point: Point data
    #   Dataset#Line: Line data
    #   Dataset#LineString: Line data
    def layer_type
      form_value = cocina_record.path("$.description.geographic.*.form[?@.type == 'type'].value").first
      return unless form_value

      case form_value
      when 'Dataset#Point'
        'circle'
      when 'Dataset#Line', 'Dataset#LineString'
        'line'
      else
        'fill'
      end
    end

    def embargo_release_date
      json.dig('access', 'embargo', 'releaseDate')&.sub(/T.*/, '') # Trim the time off the end.
    end

    def contents
      # NOTE: collections don't have structural
      return [] unless json['structural']

      Array(json.dig('structural', 'contains')).map do |file_set_json|
        Purl::ResourceJsonDeserializer.new(@druid, file_set_json).deserialize
      end
    end

    # @return [Array<String>] the list of identifiers for virtual object constituents
    def constituents
      Array(json.dig('structural', 'hasMemberOrders', 0, 'members'))
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

    def cocina_record
      @cocina_record ||= CocinaDisplay::CocinaRecord.new(json)
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
