# frozen_string_literal: true

module Embed
  class Purl
    def initialize(etag: nil, last_modified: nil, **attributes)
      @etag = etag
      @last_modified = last_modified
      self.attributes = attributes
    end

    def attributes=(hash)
      hash.each do |key, value|
        public_send(:"#{key}=", value)
      end
    end

    attr_accessor :druid, :version_id, :type, :title, :use_and_reproduction, :copyright, :contents, :constituents,
                  :collections, :license, :bounding_box, :embargo_release_date, :archived_site_url, :external_url,
                  :embargoed, :download, :view, :controlled_digital_lending,
                  :etag, :last_modified, :location_restriction, :restricted_location

    alias embargoed? embargoed
    alias controlled_digital_lending? controlled_digital_lending

    # @param [String] druid a druid without a namespace (e.g. "sx925dc9385")
    def self.find(druid, version_id = nil)
      loader = PurlJsonLoader.new(druid, version_id)
      new(etag: loader.etag, last_modified: loader.last_modified, **loader.load)
    end

    # @returns [Bool] does this have any resources that can be embeded?
    def valid?
      contents.any? || constituents.any?
    end

    def stanford_download?
      download == 'stanford'
    end

    def public?
      download == 'world'
    end

    def citation_only?
      view == 'citation-only'
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

    def resource_files
      contents.flat_map(&:files)
    end

    def downloadable_files
      resource_files.select(&:downloadable?)
    end

    def downloadable_transcript_files?
      downloadable_files.any?(&:transcript?)
    end

    def downloadable_caption_files?
      downloadable_files.any?(&:caption?)
    end

    def purl_url
      return "#{Settings.purl_url}/#{@druid}" if @version_id.blank?

      "#{Settings.purl_url}/#{@druid}/version/#{@version_id}"
    end

    def meta_json_url
      "#{purl_url}.meta_json"
    end

    def first_collection_url
      return if collections.blank?

      "#{Settings.purl_url}/#{collections.first}"
    end

    def iiif_v3_manifest_url
      "#{purl_url}/iiif3/manifest"
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
