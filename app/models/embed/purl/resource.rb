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
        @description ||= if (label_element = @resource.xpath('./label').try(:text)).present?
                           label_element
                         else
                           @resource.xpath('./attr[@name="label"]').try(:text)
                         end
      end

      def three_dimensional?
        @resource.attributes['type']&.value == '3d'
      end

      # @return [Array<ResourceFile>]
      def files
        @files ||= @resource.xpath('./file').map do |file|
          ResourceFile.new(self, file, @rights)
        end
      end

      def size
        files.sum(&:size)
      end

      # @return [ResourceFile]
      def primary_file
        files.find(&:primary?)
      end

      # @return [ResourceFile]
      def thumbnail
        files.find(&:thumbnail?)
      end

      # @return [ResourceFile]
      def vtt
        files.find(&:vtt?)
      end
    end
  end
end
