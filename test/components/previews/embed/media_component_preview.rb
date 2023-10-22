# frozen_string_literal: true

# Access this preview at:
# http://localhost:3000/rails/view_components/media_component/with_default_title

module Embed
  class MediaComponentPreview < ViewComponent::Preview
    def with_default_title
      embed_request = Embed::Request.new(url: 'https://purl.stanford.edu/bb169jj6514')
      viewer = Embed::Viewer::Media.new(embed_request)
      render(MediaComponent.new(viewer:))
    end
  end
end
