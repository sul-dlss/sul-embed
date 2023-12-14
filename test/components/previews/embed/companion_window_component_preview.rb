# frozen_string_literal: true

# Access these previews at:
# http://localhost:3000/rails/view_components/embed/companion_window_component
module Embed
  class CompanionWindowComponentPreview < ViewComponent::Preview
    layout 'preview/media'

    def public_pdf
      render_viewer_for(url: 'https://purl.stanford.edu/sq929fn8035')
    end

    private

    def render_viewer_for(url:)
      embed_request = Embed::Request.new(url:)
      viewer = Embed::ViewerFactory.new(embed_request).viewer
      render(CompanionWindowsComponent.new(viewer:))
    end
  end
end
