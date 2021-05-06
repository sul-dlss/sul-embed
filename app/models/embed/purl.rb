# frozen_string_literal: true

module Embed
  class Purl
    require 'embed/media_duration'
    require 'dor/rights_auth'
    delegate :embargoed?, :stanford_only_unrestricted?, :world_unrestricted?,
             :world_downloadable_file?, :stanford_only_downloadable_file?, to: :rights
    attr_reader :druid

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

    def valid?
      contents.any?
    end

    def contents
      @contents ||= ng_xml.xpath('//contentMetadata/resource').map do |resource|
        Purl::Resource.new(resource, rights)
      end
    end

    def rights
      @rights ||= ::Dor::RightsAuth.parse(rights_xml)
    end

    def license
      @license ||= License.new(url: license_url)
    end

    def license?
      license_url.present?
    end

    def use_and_reproduction
      ng_xml.xpath('//rightsMetadata/use/human[@type="useAndReproduction"]').first.try(:content)
    end

    def copyright
      ng_xml.xpath('//rightsMetadata/copyright').first.try(:content)
    end

    def embargo_release_date
      @embargo_release_date ||= begin
        ng_xml.xpath('//rightsMetadata/access[@type="read"]/machine/embargoReleaseDate').try(:text) if embargoed?
      end
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

    def manifest_json_response
      @manifest_json_response ||=
        begin
          conn = Faraday.new(url: manifest_json_url)
          response = conn.get do |request|
            request.options.timeout = Settings.purl_read_timeout
            request.options.open_timeout = Settings.purl_conn_timeout
          end
          raise ResourceNotAvailable unless response.success?

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
    
    def ng_xml
      @ng_xml ||= Nokogiri::XML(response)
    end

    private

    # Try each way, from most prefered to least preferred to get the license
    def license_url
      license_url_from_node || url_from_attribute || url_from_code
    end

    # This is the most modern way of determining what license to use.
    def license_url_from_node
      ng_xml.at_xpath('//rightsMetadata/use/license').try(:text).presence
    end

    # This is a slightly older way, but it can differentiate between CC 3.0 and 4.0 licenses
    def url_from_attribute
      return unless machine_node

      machine_node['uri'].presence
    end

    # This is the most legacy and least preferred way, because it only handles out of data license versions
    def url_from_code
      type, code = machine_readable_license
      return unless type && code.present?

      case type.to_s
      when 'creativeCommons'
        if code == 'pdm'
          'https://creativecommons.org/publicdomain/mark/1.0/'
        else
          "https://creativecommons.org/licenses/#{code}/3.0/legalcode"
        end
      when 'openDataCommons'
        case code
        when 'odc-pddl', 'pddl'
          'https://opendatacommons.org/licenses/pddl/1-0/'
        when 'odc-by'
          'https://opendatacommons.org/licenses/by/1-0/'
        when 'odc-odbl'
          'https://opendatacommons.org/licenses/odbl/1-0/'
        end
      end
    end

    def machine_readable_license
      [machine_node.attribute('type'), machine_node.text] if machine_node
    end

    def machine_node
      @machine_node ||= ng_xml.at_xpath('//rightsMetadata/use/machine[@type="openDataCommons" or @type="creativeCommons"]')
    end

    def rights_xml
      @rights_xml ||= ng_xml.xpath('//rightsMetadata').to_s
    end

    def purl_xml_url
      "#{Settings.purl_url}/#{@druid}.xml"
    end

    def response
      @response ||=
        begin
          conn = Faraday.new(url: purl_xml_url)

          response = conn.get do |request|
            request.options.timeout = Settings.purl_read_timeout
            request.options.open_timeout = Settings.purl_conn_timeout
          end

          raise ResourceNotAvailable unless response.success?

          response.body
        rescue Faraday::ConnectionFailed, Faraday::TimeoutError
          nil
        end
    end

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

    class Resource
      def initialize(resource, rights)
        @resource = resource
        @rights = rights
      end

      def sequence
        @resource.attributes['sequence'].try(:value)
      end

      def type
        @resource.attributes['type'].try(:value)
      end

      def description
        @description ||= if (label_element = @resource.xpath('./label').try(:text)).present?
                           label_element
                         else
                           @resource.xpath('./attr[@name="label"]').try(:text)
                         end
      end

      def object_thumbnail?
        @resource.attributes['thumb'].try(:value) == 'yes' || type == 'thumb'
      end

      def three_dimensional?
        @resource.attributes['type']&.value == '3d'
      end

      def files
        @files ||= @resource.xpath('./file').map do |file|
          ResourceFile.new(self, file, @rights)
        end
      end

      def primary_file
        files.find(&:primary?)
      end

      def thumbnail
        files.find(&:thumbnail?)
      end

      class ResourceFile
        def initialize(resource, file, rights)
          @resource = resource
          @file = file
          @rights = rights
        end

        def label
          return resource.description if resource.description.present?

          title
        end

        def title
          @file.attributes['id'].try(:value)
        end

        def primary?
          primary_types = Settings.primary_mimetypes[resource.type] || []
          !thumbnail? && primary_types.include?(mimetype)
        end

        def thumbnail
          resource.files.find(&:thumbnail?)
        end

        def thumbnail?
          return true if resource.object_thumbnail?
          return false unless image?

          Settings.resource_types_that_contain_thumbnails.include?(resource.type)
        end

        def pdf?
          mimetype == 'application/pdf'
        end

        def mimetype
          @file.attributes['mimetype'].try(:value)
        end

        def previewable?
          preview_types.include?(mimetype)
        end

        # unused (9/2016) - candidate for removal?
        def image?
          mimetype =~ %r{image/jp2}i
        end

        def size
          @file.attributes['size'].try(:value)
        end

        # unused (9/2016) - candidate for removal?
        def height
          @file.xpath('./*/@height').first.try(:text) if @file.xpath('./*/@height').present?
        end

        # unused (9/2016) - candidate for removal?
        def width
          @file.xpath('./*/@width').first.try(:text) if @file.xpath('./*/@width').present?
        end

        def duration
          md = Embed::MediaDuration.new(@file.xpath('./*[@duration]').first) if @file.xpath('./*/@duration').present?
          md&.to_s
        end

        # unused (9/2016) - candidate for removal?
        def location
          @file.xpath('./location[@type="url"]').first.try(:text) if @file.xpath('./location[@type="url"]').present?
        end

        def stanford_only?
          value, _rule = @rights.stanford_only_rights_for_file(title)

          value
        end

        def location_restricted?
          @rights.restricted_by_location?(title)
        end

        def world_downloadable?
          @rights.world_downloadable_file?(@file.attributes['id'])
        end

        private

        attr_reader :resource

        def preview_types
          ['image/jp2']
        end
      end
    end
  end
end
