# frozen_string_literal: true

module CompanionWindows
  class ContentListComponent < ViewComponent::Base
    def initialize(viewer:)
      @viewer = viewer
    end

    attr_reader :viewer

    def document_viewer?
      viewer.instance_of?(::Embed::Viewer::DocumentViewer)
    end

    def resource_files_collection
      viewer.purl_object.resource_files
    end
  end
end
