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
        title: display_title,
        contents:,
        virtual_object: virtual_object?,
        collections: containing_collections,
        copyright:,
        license: license_description,
        use_and_reproduction:,
        embargo_release_date:,
        bounding_box:,
        layer_type:,
        archived_site_url:,
        embargoed:,
        location_restriction:,
        restricted_location:,
        download: download_rights,
        view: view_rights,
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

    delegate :containing_collections, :copyright, :display_title, :download_rights, :license_description,
             :use_and_reproduction, :view_rights, :virtual_object?, to: :cocina_record, private: true

    def embargoed # rubocop:disable Naming/PredicateMethod
      cocina_record.path('$.access.embargo').any?
    end

    def location_restriction
      return 'download' if cocina_record.location_only_downloadable?
      return 'view' if cocina_record.location_only_viewable?

      false
    end

    def restricted_location
      return unless location_restriction

      locations = Settings.locations
      locations[cocina_record.location_rights] || locations[:fallback]
    end

    def controlled_digital_lending
      cocina_record.path('$.access.controlledDigitalLending').first
    end

    def archived_site_url
      cocina_record.urls.find { |url| url.link_text == 'Archived website' }&.to_s
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
      cocina_record.path('$.access.embargo.releaseDate').first&.sub(/T.*/, '') # Trim the time off the end.
    end

    def contents
      cocina_record.filesets.map do |file_set|
        Purl::ResourceJsonDeserializer.new(@druid, file_set.cocina).deserialize
      end
    end

    def type
      cocina_type = cocina_record.content_type
      LEGACY_TYPE_MAP.fetch(cocina_type, cocina_type)
    end

    def cocina_record
      @cocina_record ||= CocinaDisplay::CocinaRecord.from_json(response)
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
