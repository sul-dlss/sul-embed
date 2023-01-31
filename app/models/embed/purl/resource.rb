# frozen_string_literal: true

module Embed
  class Purl
    class Resource
      def initialize(resource, rights)
        @resource = resource
        @rights = rights
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
    end
  end
end
