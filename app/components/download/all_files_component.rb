# frozen_string_literal: true

module Download
  class AllFilesComponent < ViewComponent::Base
    # @param [#purl_object] viewer
    def initialize(viewer:)
      @viewer = viewer
    end

    attr_reader :viewer

    delegate :purl_object, :download_url, :any_stanford_only_files?, to: :viewer
    delegate :downloadable_files, to: :purl_object

    def render?
      !viewer.is_a?(Embed::Viewer::Media)
    end

    # Returns true or false whether the viewer should display the Download All
    # link. The limits were determined in testing and may need to be adjusted
    # based on experience with download performance and any changes in the
    # Stacks API. It returns false when there is just one file because the
    # file download link will suffice for that.
    def display_download_all?
      purl_object.size < 10_737_418_240 && downloadable_files.length < 3000
    end

    def pretty_filesize
      viewer.pretty_filesize(purl_object.size)
    end
  end
end
