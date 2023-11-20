# frozen_string_literal: true

module Embed
  class Purl
    require 'embed/media_duration'
    require 'dor/rights_auth'
    delegate :embargoed?, :citation_only?, :stanford_only_unrestricted?, :world_unrestricted?,
             :world_downloadable_file?, :stanford_only_downloadable_file?, to: :rights

    def initialize(attributes = {})
      self.attributes = attributes
    end

    def attributes=(hash)
      hash.each do |key, value|
        public_send("#{key}=", value)
      end
    end

    attr_accessor :druid, :type, :title, :use_and_reproduction, :copyright, :contents, :collections,
                  :license, :envelope, :embargo_release_date, :archived_site_url, :external_url, :rights

    # @param [String] druid a druid without a namespace (e.g. "sx925dc9385")
    def self.find(druid)
      new(PurlXmlLoader.load(druid))
    end

    # @returns [Bool] does this have any resources that can be embeded?
    def valid?
      contents.any?
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
