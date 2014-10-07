module Embed
  class PURL
    require 'dor/rights_auth'
    delegate :embargoed?, to: :rights
    def initialize(druid)
      @druid = druid
    end

    def title
      @title ||= ng_xml.xpath('//identityMetadata/objectLabel').try(:text)
    end

    def type
      @type ||= ng_xml.xpath('//contentMetadata').first.attributes['type'].try(:value)
    end

    def contents
      @contents ||= ng_xml.xpath('//contentMetadata/resource').map do |resource|
        PURL::Resource.new(resource, rights)
      end
    end

    def rights
      @rights ||= ::Dor::RightsAuth.parse(rights_xml)
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

    private

    def rights_xml
      @rights_xml ||= ng_xml.xpath('//rightsMetadata').to_s
    end

    def purl_url
      "#{Settings.purl_url}/#{@druid}.xml"
    end

    def response
      @response ||= begin
        conn = Faraday.new(url: purl_url)
        conn.get do |request|
          request.options = {
            timeout: 2,
            open_timeout: 2
          }
        end.body
      rescue Faraday::Error::ConnectionFailed => error
        nil
      rescue Faraday::Error::TimeoutError => error
        nil
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
      def files
        @files ||= @resource.xpath('./file').map do |file|
          ResourceFile.new(file, @rights)
        end
      end
      class ResourceFile
        def initialize(file, rights)
          @file = file
          @rights = rights
        end
        def title
          @file.attributes['id'].try(:value)
        end
        def mimetype
          @file.attributes['mimetype'].try(:value)
        end
        def size
          @file.attributes['size'].try(:value)
        end
        def image_height
          @file.xpath('./imageData').first.attributes['height'].try(:text) if has_image_data?
        end
        def image_width
          @file.xpath('./imageData').first.attributes['width'].try(:text) if has_image_data?
        end
        def location
          @file.xpath('./location[@type="url"]').first.try(:text) if has_location_data?
        end
        def stanford_only?
          @rights.stanford_only_unrestricted_file?(title)
        end
        private
        def has_image_data?
          @file.xpath('./imageData').present?
        end
        def has_location_data?
          @file.xpath('./location[@type="url"]').present?
        end
      end
    end
  end
end

