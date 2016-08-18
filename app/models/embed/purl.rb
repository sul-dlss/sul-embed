module Embed
  class PURL
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

    class Duration < ISO8601::Duration
      def to_s
        return nil unless supported_duration?

        # build up a list of the fields we want to use for output string
        field_accumulator = []
        [:years, :months, :days, :hours, :minutes, :seconds].each do |atom_type|
          atom_val = atoms[atom_type]
          # if we've already started accumulating fields, or this field is non-zero, add this field to the list.
          # if we've hit the minutes field, start accumulating no matter what, since we always want to show minutes
          # and seconds.
          field_accumulator << atom_val if !field_accumulator.empty? || atom_val != 0 || atom_type == :minutes
        end

        # zero pad any field after the first, join with colons (e.g., returns '1:02:03' for 'P0DT1H2M3S',
        # '2:03' for 'PT2M3S').
        field_accumulator.map.with_index do |atom_val, idx|
          (idx > 0) ? atom_val.to_i.to_s.rjust(2, '0') : atom_val.to_i.to_s
        end.join ':'
      end

      private

      # though they're valid ISO8601 durations, we don't support negative durations or durations specified in
      # weeks, because those flavors of duration don't make much sense for the running time of a piece of media.
      def supported_duration?
        errors = []
        errors << "#{self.class} does not support specifying durations in weeks" if atoms[:weeks] != 0
        errors << "#{self.class} does not support specifying negative durations" if atoms.values.any? { |val| val < 0 }
        return true if errors.empty?

        errors.each { |e| Honeybadger.notify(e) }
        false
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

      # get first file of appropriate mime type
      def media_file
        files.find { |file| file.mimetype.match "^#{type}\/" }
      end

      # get first image file (if any) for the resource
      def media_thumb
        files.find(&:image?)
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

        def previewable?
          preview_types.include?(mimetype)
        end

        def image?
          mimetype =~ /image\/jp2/i
        end

        def size
          @file.attributes['size'].try(:value)
        end

        def image_height
          @file.xpath('./imageData').first.attributes['height'].try(:text) if image_data?
        end

        def image_width
          @file.xpath('./imageData').first.attributes['width'].try(:text) if image_data?
        end

        def video_height
          @file.xpath('./videoData').first.attributes['height'].try(:text) if video_data?
        end

        def video_width
          @file.xpath('./videoData').first.attributes['width'].try(:text) if video_data?
        end

        def video_duration
          Duration.new(video_duration_attr_str) if video_duration_attr_str
        rescue ISO8601::Errors::UnknownPattern
          Honeybadger.notify(
            "ResourceFile\#video_duration ISO8601::Errors::UnknownPattern: '#{video_duration_attr_str}'"
          )
          nil
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

        def image_data?
          @file.xpath('./imageData').present?
        end

        def video_data?
          @file.xpath('./videoData').present?
        end

        def video_duration_attr_str
          @file.xpath('./videoData').first.attributes['duration'].try(:text) if video_data?
        end

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
