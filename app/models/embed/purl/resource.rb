# frozen_string_literal: true

module Embed
  class Purl
    class Resource
      # @param [String] druid identifier without a namespace
      # @param [String] type the resource type
      # @param [String] description the resource description
      # @param [Array<ResourceFile>] files
      def initialize(attributes = {})
        @files = []
        self.attributes = attributes
      end

      def attributes=(hash)
        hash.each do |key, value|
          public_send(:"#{key}=", value)
        end
      end

      attr_accessor :druid, :type, :description, :files, :version

      # In deserialize, description is the label
      # https://github.com/sul-dlss/sul-embed/blob/784e6dd51fd9fbe18d11ff63e2640bea010ab0dc/app/models/embed/purl/resource_json_deserializer.rb#L17
      def label
        description
      end

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

      # Sort the caption files by language label so we can display them in alphabetical order in the
      # captions options list.
      #
      # @return [Array<ResourceFile>]
      def caption_files
        files.select(&:caption?)
      end
    end
  end
end
