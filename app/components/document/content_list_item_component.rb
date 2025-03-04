# frozen_string_literal: true

module Document
  # Draws the content list for the Document viewer
  class ContentListItemComponent < ViewComponent::Base
    def initialize(content_list_item:, viewer:, content_list_item_counter:)
      @file = content_list_item
      @viewer = viewer
      @index = content_list_item_counter
    end
    attr_reader :file, :viewer, :index

    def url
      file.file_url
    end

    def download_label
      file.label_or_filename
    end

    def classes
      default_classes = 'file-thumb'
      return default_classes unless index.zero?

      "#{default_classes} active"
    end

    # NOTE: when other content types make use of this component, add other JS methods to the content_list_controller.js
    # to define how to swap new content into the main panel, and then set the method below name below. The JS method
    # defined below in content_list_controller.js will be trigged when the user clicks on the file, and it will be
    # passed the URL
    def show_method
      'showPdf' if viewer.instance_of?(::Embed::Viewer::DocumentViewer)
    end

    def file_type_icon
      viewer.file_type_icon(file.mimetype)
    end

    # Only PDF content is rendered in this panel for now, can be extended later to other content types
    # Media content does not need this component since it uses custom javascript to render thumbnails and link to
    # content
    def render?
      # do not render any file that is not a PDF
      url.ends_with?('.pdf')
    end
  end
end
