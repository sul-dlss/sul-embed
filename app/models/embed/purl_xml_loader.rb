# frozen_string_literal: true

module Embed
  class PurlXmlLoader # rubocop:disable Metrics/ClassLength
    def initialize(druid)
      @druid = druid
    end

    def self.load(druid)
      new(druid).load
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
        envelope:,
        archived_site_url:,
        external_url:,
        rights:
      }
    end

    private

    def archived_site_url
      ng_xml.xpath(
        '//mods:url[@displayLabel="Archived website"]',
        'mods' => 'http://www.loc.gov/mods/v3'
      )&.text
    end

    def external_url
      ng_xml.xpath('//dc:identifier', 'dc' => 'http://purl.org/dc/elements/1.1/').try(:text)
    end

    def collections
      ng_xml.at_xpath(
        '//fedora:isMemberOf',
        'xmlns:fedora' => 'info:fedora/fedora-system:def/relations-external#'
      )&.map { |_name, value| value.gsub('info:fedora/druid:', '') } || []
    end

    def envelope
      ng_xml.at_xpath('//gml:Envelope', 'gml' => 'http://www.opengis.net/gml/3.2/')
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
      # TODO: we have to pass `forindex=true` here so that we can subsequently call citation_only?
      #       This is pretty slow.
      @rights ||= ::Dor::RightsAuth.parse(rights_xml, true)
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

    def response # rubocop:disable Metrics/MethodLength
      @response ||=
        begin
          conn = Faraday.new(url: purl_xml_url)

          response = conn.get do |request|
            request.options.timeout = Settings.purl_read_timeout
            request.options.open_timeout = Settings.purl_conn_timeout
          end

          unless response.success?
            raise Purl::ResourceNotAvailable,
                  "Resource unavailable #{purl_xml_url} (status: #{response.status})"
          end

          response.body
        rescue Faraday::ConnectionFailed, Faraday::TimeoutError
          nil
        end
    end
  end
end
