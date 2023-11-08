# frozen_string_literal: true

module Embed
  # rubocop:disable Metrics/ClassLength
  class Purl
    require 'embed/media_duration'
    require 'dor/rights_auth'
    delegate :embargoed?, :citation_only?, :stanford_only_unrestricted?, :world_unrestricted?,
             :world_downloadable_file?, :stanford_only_downloadable_file?, to: :rights
    attr_reader :druid

    # @param [String] druid a druid without a namespace (e.g. "sx925dc9385")
    def initialize(druid)
      @druid = druid
    end

    def title
      @title ||= ng_xml.xpath('//dc:title', 'dc' => 'http://purl.org/dc/elements/1.1/').try(:text)
    end

    def type
      @type ||= begin
        content_metadata = ng_xml.xpath('//contentMetadata').first
        content_metadata.attributes['type'].try(:value) if content_metadata.present?
      end
    end

    # @returns [Bool] does this have any resources that can be embeded?
    def valid?
      contents.any?
    end

    def contents
      @contents ||= ng_xml.xpath('//contentMetadata/resource').map do |resource|
        Purl::Resource.new(@druid, resource, rights)
      end
    end

    def hierarchical_contents
      @hierarchical_contents ||= Embed::HierarchicalContents.contents(contents)
    end

    def hierarchical?
      @hierarchical ||= hierarchical_contents.files.length != contents.sum { |resource| resource.files.length }
    end

    def size
      contents.sum(&:size)
    end

    def rights
      @rights ||= ::Dor::RightsAuth.parse(rights_xml)
    end

    def use_and_reproduction
      ng_xml.xpath('//rightsMetadata/use/human[@type="useAndReproduction"]').first.try(:content)
    end

    def copyright
      ng_xml.xpath('//rightsMetadata/copyright').first.try(:content)
    end

    def license
      cc_license || odc_license || mods_license
    end

    def embargo_release_date
      return unless embargoed?

      @embargo_release_date ||= ng_xml.xpath('//rightsMetadata/access[@type="read"]/machine/embargoReleaseDate')&.text
    end

    def ng_xml
      @ng_xml ||= Nokogiri::XML(response)
    end

    def all_resource_files
      contents.map(&:files).flatten
    end

    def downloadable_files
      all_resource_files.select do |rf|
        world_downloadable_file?(rf.title) || stanford_only_downloadable_file?(rf.title)
      end
    end

    def purl_url
      "#{Settings.purl_url}/#{@druid}"
    end

    def bounding_box
      Embed::Envelope.new(envelope).to_bounding_box
    end

    def envelope
      ng_xml.at_xpath('//gml:Envelope', 'gml' => 'http://www.opengis.net/gml/3.2/')
    end

    ##
    # Returns true if the object is publicly accessible based on the
    #  rights_metadata
    # @return [Boolean] true if the object is public, otherwise false
    def public?
      rights.world_unrestricted?
    end

    def manifest_json_url
      "#{Settings.purl_url}/#{druid}/iiif/manifest"
    end

    def manifest_json_response # rubocop:disable Metrics/MethodLength
      @manifest_json_response ||=
        begin
          conn = Faraday.new(url: manifest_json_url)
          response = conn.get do |request|
            request.options.timeout = Settings.purl_read_timeout
            request.options.open_timeout = Settings.purl_conn_timeout
          end
          unless response.success?
            raise ResourceNotAvailable,
                  "Resource unavailable #{manifest_json_url} (status: #{response.status})"
          end

          response.body
        rescue Faraday::ConnectionFailed, Faraday::TimeoutError
          raise ResourceNotAvailable
        end
    end

    def collections
      ng_xml.at_xpath(
        '//fedora:isMemberOf',
        'xmlns:fedora' => 'info:fedora/fedora-system:def/relations-external#'
      )&.map { |_name, value| value.gsub('info:fedora/druid:', '') } || []
    end

    private

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

    def rights_xml
      @rights_xml ||= ng_xml.xpath('//rightsMetadata').to_s
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
            raise ResourceNotAvailable,
                  "Resource unavailable #{purl_xml_url} (status: #{response.status})"
          end

          response.body
        rescue Faraday::ConnectionFailed, Faraday::TimeoutError
          nil
        end
    end
    # rubocop:enable Metrics/ClassLength

    class ResourceNotAvailable < StandardError
      def initialize(msg = 'The requested PURL resource was not available')
        super
      end
    end

    class ResourceNotEmbeddable < StandardError
      def initialize(msg = 'The requested PURL resource was not embeddable.')
        super
      end
    end
  end
end
