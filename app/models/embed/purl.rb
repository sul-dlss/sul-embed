module Embed
  class PURL
    require 'embed/media_duration'
    require 'dor/rights_auth'
    delegate :embargoed?, :stanford_only_unrestricted?, :world_unrestricted?, to: :rights
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
        PURL::Resource.new(resource, rights)
      end
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
      cc_license || odc_licence
    end

    def embargo_release_date
      @embargo_release_date ||= begin
        if embargoed?
          ng_xml.xpath('//rightsMetadata/access[@type="read"]/machine/embargoReleaseDate').try(:text)
        end
      end
    end

    def ng_xml
      @ng_xml ||= Nokogiri::XML(response)
    end

    def all_resource_files
      contents.map(&:files).flatten
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

    private

    def cc_license
      { human: cc_license_human, machine: cc_license_machine } if cc_license_human.present? && cc_license_machine.present?
    end

    def cc_license_machine
      ng_xml.xpath('//rightsMetadata/use/machine[@type="creativeCommons"]').first.try(:content)
    end

    def cc_license_human
      ng_xml.xpath('//rightsMetadata/use/human[@type="creativeCommons"]').first.try(:content)
    end

    def odc_licence
      { human: odc_licence_human, machine: odc_licence_machine } if odc_licence_human.present? && odc_licence_machine.present?
    end

    def odc_licence_human
      ng_xml.xpath('//rightsMetadata/use/human[@type="openDataCommons"]').first.try(:content)
    end

    def odc_licence_machine
      ng_xml.xpath('//rightsMetadata/use/machine[@type="openDataCommons"]').first.try(:content)
    end

    def rights_xml
      @rights_xml ||= ng_xml.xpath('//rightsMetadata').to_s
    end

    def purl_xml_url
      "#{Settings.purl_url}/#{@druid}.xml"
    end

    def response
      @response ||= begin
        conn = Faraday.new(url: purl_xml_url)
        response = conn.get do |request|
          request.options.timeout = Settings.purl_read_timeout
          request.options.open_timeout = Settings.purl_conn_timeout
        end
        raise ResourceNotAvailable unless response.success?
        response.body
      rescue Faraday::Error::ConnectionFailed, Faraday::Error::TimeoutError
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

      def files
        @files ||= @resource.xpath('./file').map do |file|
          ResourceFile.new(self, file, @rights)
        end
      end

      def non_thumbnail_files
        files.reject(&:thumbnail?)
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

        def thumbnail
          resource.files.find(&:thumbnail?).try(:title)
        end

        def thumbnail?
          return true if resource.object_thumbnail?
          return false unless image?
          Settings.resource_types_that_contain_thumbnails.include?(resource.type)
        end

        def mimetype
          @file.attributes['mimetype'].try(:value)
        end

        def previewable?
          preview_types.include?(mimetype)
        end

        # unused (9/2016) - candidate for removal?
        def image?
          mimetype =~ /image\/jp2/i
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
          md.to_s if md
        end

        def location
          @file.xpath('./location[@type="url"]').first.try(:text) if location_data?
        end

        def stanford_only?
          @rights.stanford_only_unrestricted_file?(title)
        end

        def location_restricted?
          @rights.restricted_by_location?(title)
        end

        private

        attr_reader :resource

        def location_data?
          @file.xpath('./location[@type="url"]').present?
        end

        def preview_types
          ['image/jp2']
        end
      end
    end
  end
end
