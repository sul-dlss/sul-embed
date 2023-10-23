# frozen_string_literal: true

# Access this preview at:
# http://localhost:3000/rails/view_components/embed/media_with_companion_windows_component/with_default_title

module Embed
  class MediaWithCompanionWindowsComponentPreview < ViewComponent::Preview
    def with_default_title
      embed_request = Embed::Request.new(url: 'https://purl.stanford.edu/bb169jj6514')
      viewer = Embed::Viewer::Media.new(embed_request)
      render(MediaWithCompanionWindowsComponent.new(viewer:))
    end
  end
end
