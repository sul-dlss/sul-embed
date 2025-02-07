# frozen_string_literal: true

module Download
  class FileListComponent < ViewComponent::Base
    # @param [#purl_object] viewer
    def initialize(viewer:)
      @viewer = viewer
    end

    attr_reader :viewer

    delegate :purl_object, to: :viewer
    delegate :downloadable_files, to: :purl_object

    def grouped_downloadable_files
      purl_object.contents.map do |item|
        item.dup.tap { |obj| obj.files = obj.files.select(&:downloadable?) }
      end
    end

    # Determine if we need to group files.
    # For example, if a media file has a caption or transcript
    # we will want to group the caption with the media file.
    def grouped_files?
      downloadable_files.any? { |file| file.caption? || file.transcript? }
    end
  end
end
