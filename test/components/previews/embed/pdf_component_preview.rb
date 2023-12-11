# frozen_string_literal: true

# Access these previews at:
# http://localhost:3000/rails/view_components/embed/pdf_component
module Embed
  class PdfComponentPreview < ViewComponent::Preview
    layout 'preview/pdf'

    def public
      render_viewer_for(url: 'https://purl.stanford.edu/sq929fn8035')
    end

    private

    def render_viewer_for(url:)
      embed_request = Embed::Request.new(url:)
      viewer = Embed::Viewer::PdfViewer.new(embed_request)
      render(PdfComponent.new(viewer:))
    end
  end
end
