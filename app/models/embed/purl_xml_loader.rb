# frozen_string_literal: true

module Embed
  class PurlXmlLoader # rubocop:disable Metrics/ClassLength
    def initialize(druid)
      @druid = druid
    end

    def load # rubocop:disable Metrics/MethodLength
      {
        druid: @druid,
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
      rights.embargoed?
    end

    def stanford_only_unrestricted
      rights.stanford_only_unrestricted?
    end

    def controlled_digital_lending
      rights.controlled_digital_lending?
    end

    def public
      rights.world_unrestricted?
    end

    def archived_site_url
      ng_xml.xpath(
        '//mods:url[@displayLabel="Archived website"]',
        'mods' => 'http://www.loc.gov/mods/v3'
      )&.text
    end

    def collections
      ng_xml.at_xpath(
        '//fedora:isMemberOf',
        'xmlns:fedora' => 'info:fedora/fedora-system:def/relations-external#'
      )&.map { |_name, value| value.gsub('info:fedora/druid:', '') } || []
    end

    def bounding_box
      node = ng_xml.at_xpath('//gml:Envelope', 'gml' => 'http://www.opengis.net/gml/3.2/')
      return unless node

      Embed::Envelope.new(node).to_bounding_box
    end

    def embargo_release_date
      return unless rights.embargoed?

      ng_xml.xpath('//rightsMetadata/access[@type="read"]/machine/embargoReleaseDate')&.text
    end

    def contents
      ng_xml.xpath('//contentMetadata/resource').map do |resource|
        Purl::ResourceXmlDeserializer.new(@druid, resource, rights).deserialize
      end
    end

    def license
      cc_license || odc_license || mods_license
    end

    def mods_license
      ng_xml
        .xpath('//mods:accessCondition[@type="license"]', 'mods' => 'http://www.loc.gov/mods/v3')
        .first
        .try(:content)
        .try(:strip)
    end

    def cc_license
      ng_xml.xpath('//rightsMetadata/use/human[@type="creativeCommons"]').first.try(:content)
    end

    def odc_license
      ng_xml.xpath('//rightsMetadata/use/human[@type="openDataCommons"]').first.try(:content)
    end

    def rights
      @rights ||= ::Dor::RightsAuth.parse(rights_xml)
    end

    def rights_xml
      ng_xml.xpath('//rightsMetadata').to_s
    end

    def type
      content_metadata = ng_xml.xpath('//contentMetadata').first
      content_metadata.attributes['type'].try(:value) if content_metadata.present?
    end

    def title
      ng_xml.xpath('//dc:title', 'dc' => 'http://purl.org/dc/elements/1.1/').try(:text)
    end

    def use_and_reproduction
      ng_xml.xpath('//rightsMetadata/use/human[@type="useAndReproduction"]').first.try(:content)
    end

    def copyright
      ng_xml.xpath('//rightsMetadata/copyright').first.try(:content)
    end

    def ng_xml
      @ng_xml ||= Nokogiri::XML(response)
    end

    def purl_xml_url
      "#{Settings.purl_url}/#{@druid}.xml"
    end

    def http_response
      @http_response ||= begin
        conn = Faraday.new(url: purl_xml_url)

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
                  "Resource unavailable #{purl_xml_url} (status: #{http_response.status})"
          end

          http_response.body
        rescue Faraday::ConnectionFailed, Faraday::TimeoutError
          nil
        end
    end
  end
end
