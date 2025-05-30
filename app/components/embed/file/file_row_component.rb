# frozen_string_literal: true

module Embed
  module File
    class FileRowComponent < ViewComponent::Base
      # @param [Embed::Viewer::File]
      # @param [Embed::Purl::ResourceFile] file
      def initialize(viewer:, file:, pos_in_set: nil, set_size: nil, level: 0)
        @viewer = viewer
        @file = file
        @pos_in_set = pos_in_set
        @set_size = set_size
        @level = level
      end

      attr_reader :viewer, :file, :pos_in_set, :set_size, :level

      delegate :label, :no_download?, to: :file

      def file_size_text
        viewer.file_size_text(file.size)
      end

      def title
        file.hierarchical_title
      end

      def filepath
        file.title.downcase
      end

      def first_td_style
        "padding-left: #{((level - 1) * 3) + 3.5}ch;"
      end

      def version
        viewer.purl_object.version_id
      end

      def url
        file.file_url(download: false, version:)
      end

      def file_type_icon
        viewer.file_type_icon(file.mimetype)
      end
    end
  end
end
