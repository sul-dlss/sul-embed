# frozen_string_literal: true

class ContentListItemComponent < ViewComponent::Base
  def initialize(content_list_item:, viewer_class:)
    @file = content_list_item
    @viewer_class = viewer_class
  end
  attr_reader :file, :viewer_class

  def url
    file.file_url
  end

  def download_label
    file.label_or_filename
  end

  # NOTE: when other content types make use of this component, add other JS methods to the content_list_controller.js to
  # define how to swap new content into the main panel, and then set the method below name below. The JS method defined
  # below in content_list_controller.js will be trigged when the user clicks on the file, and it will be passed the URL
  def show_method
    case viewer_class
    when 'Embed::Viewer::PdfViewer'
      'showPdf'
    end
  end

  # Only PDF content is rendered in this panel for now, can be extended later to other content types
  # Media content does not need this component since it uses custom javascript to render thumbnails and link to content
  def render?
    # do not render any file that is not a PDF
    return true if (viewer_class == 'Embed::Viewer::PdfViewer') && url.ends_with?('.pdf')

    false
  end
end
