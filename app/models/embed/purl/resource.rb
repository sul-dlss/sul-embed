# frozen_string_literal: true

module Embed
  class Purl
    class Resource
      # @param [String] druid identifier without a namespace
      # @param [String] type the resource type
      # @param [String] description the resource description
      # @param [Array<ResourceFile>] files
      def initialize(druid:, type:, description:, files: [])
        @druid = druid
        @type = type
        @description = description
        @files = files
      end

      attr_reader :druid, :type, :description, :files

      def three_dimensional?
        type == '3d'
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
