# frozen_string_literal: true

# Access these previews at:
# http://localhost:3000/rails/view_components/embed/model_component
module Embed
  class ModelComponentPreview < ViewComponent::Preview
    layout 'preview/model'

    def public
      render_viewer_for(url: 'https://purl.stanford.edu/bb648mk7250')
    end

    private

    def render_viewer_for(url:)
      embed_request = Embed::Request.new(url:, new_viewer: 'true')
      viewer = Embed::Viewer::ModelViewer.new(embed_request)
      render(viewer.component.new(viewer:))
    end
  end
end
