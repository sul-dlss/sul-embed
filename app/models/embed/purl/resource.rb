# frozen_string_literal: true

module Embed
  class Purl
    class Resource
      # @param [String] druid identifier without a namespace
      # @param [Nokogiri::XML::Element] resource
      # @param [Dor::RightsAuth] rights
      def initialize(druid, resource, rights)
        @druid = druid
        @resource = resource
        @rights = rights
      end

      attr_reader :druid

      def type
        @resource.attributes['type'].value
      end

      def description
        @description ||= @resource.xpath('./label').text
      end

      def three_dimensional?
        @resource.attributes['type']&.value == '3d'
      end

      # @return [Array<ResourceFile>]
      def files
        @files ||= @resource.xpath('./file').map do |file|
          FileXmlDeserializer.new(druid, description, file, @rights).deserialize
        end
      end

      def size
        files.sum(&:size)
      end

      # @return [ResourceFile]
      def primary_file
        files.find { |file| primary_types.include?(file.mimetype) }
      end

      def primary_types
        @primary_types ||= Array(Settings.primary_mimetypes[type])
      end

      # @return [ResourceFile]
      def thumbnail
        return unless Settings.resource_types_that_contain_thumbnails.include?(type)

        files.find(&:image?)
      end

      # @return [Array<ResourceFile>]
      def caption_files
        files.select(&:vtt?)
      end
    end
  end
end
