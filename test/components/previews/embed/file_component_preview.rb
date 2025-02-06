# frozen_string_literal: true

# Access these previews at:
# http://localhost:3000/rails/view_components/embed/file_component
module Embed
  class FileComponentPreview < ViewComponent::Preview
    layout 'preview/file'

    def hierarchy
      render_viewer_for(url: 'https://purl.stanford.edu/fg478vy8624')
    end

    private

    def render_viewer_for(url:)
      embed_request = Embed::Request.new(url:, new_viewer: 'true')
      viewer = Embed::Viewer::File.new(embed_request)
      render(viewer.component.new(viewer:))
    end
  end
end
