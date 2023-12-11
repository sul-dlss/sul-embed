# frozen_string_literal: true

# Access these previews at:
# http://localhost:3000/rails/view_components/embed/pdf_component
module Embed
  class GeoComponentPreview < ViewComponent::Preview
    layout 'preview/geo'

    def public
      render_viewer_for(url: 'https://purl.stanford.edu/bc843cm1713')
    end

    private

    def render_viewer_for(url:)
      embed_request = Embed::Request.new(url:)
      viewer = Embed::Viewer::Geo.new(embed_request)
      render(viewer.component.new(viewer:))
    end
  end
end
