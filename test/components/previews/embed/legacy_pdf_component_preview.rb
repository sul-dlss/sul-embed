# frozen_string_literal: true

# Access these previews at:
# http://localhost:3000/rails/view_components/embed/pdf_component
module Embed
  class LegacyPdfComponentPreview < ViewComponent::Preview
    layout 'preview/legacy_pdf'

    def public
      render_viewer_for(url: 'https://purl.stanford.edu/sq929fn8035')
    end

    def stanford_only
      render_viewer_for(url: 'https://purl.stanford.edu/jr789rw2402')
    end

    def citation_only
      render_viewer_for(url: 'https://purl.stanford.edu/bz673hm0344')
    end

    private

    def render_viewer_for(url:)
      embed_request = Embed::Request.new(url:)
      viewer = Embed::ViewerFactory.new(embed_request).viewer
      render(LegacyPdfComponent.new(viewer:))
    end
  end
end
