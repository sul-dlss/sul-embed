# frozen_string_literal: true

module CompanionWindows
  class ContentListItemComponent < ViewComponent::Base
    def initialize(content_list_item:, viewer:)
      @file = content_list_item
      @viewer = viewer
    end
    attr_reader :file, :viewer

    def url
      file.file_url
    end

    def download_label
      file.label_or_filename
    end

    # NOTE: when other content types make use of this component, add other JS methods to the content_list_controller.js
    # to define how to swap new content into the main panel, and then set the method below name below. The JS method
    # defined below in content_list_controller.js will be trigged when the user clicks on the file, and it will be
    # passed the URL
    def show_method
      'showPdf' if viewer.instance_of?(::Embed::Viewer::PdfViewer)
    end

    def file_type_icon
      viewer.file_type_icon(file.mimetype)
    end

    # Only PDF content is rendered in this panel for now, can be extended later to other content types
    # Media content does not need this component since it uses custom javascript to render thumbnails and link to
    # content
    def render?
      # do not render any file that is not a PDF
      return true if viewer.instance_of?(::Embed::Viewer::PdfViewer) && url.ends_with?('.pdf')

      false
    end
  end
end
