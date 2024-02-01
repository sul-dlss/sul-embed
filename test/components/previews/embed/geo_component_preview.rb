# frozen_string_literal: true

# Access these previews at:
# http://localhost:3000/rails/view_components/embed/pdf_component
module Embed
  class GeoComponentPreview < ViewComponent::Preview
    layout 'preview/geo'

    def public_raster
      render_viewer_for(url: 'https://purl.stanford.edu/tg926kp6619')
    end

    def public_vector
      render_viewer_for(url: 'https://purl.stanford.edu/cz128vq0535')
    end

    private

    def render_viewer_for(url:)
      embed_request = Embed::Request.new(url:)
      viewer = Embed::Viewer::Geo.new(embed_request)
      render(viewer.component.new(viewer:))
    end
  end
end
