# frozen_string_literal: true

# Access this preview at:
# http://localhost:3000/rails/view_components/embed/media_with_companion_windows_component/with_default_title

module Embed
  class MediaWithCompanionWindowsComponentPreview < ViewComponent::Preview
    def with_audio
      embed_request = Embed::Request.new(url: 'https://purl.stanford.edu/gj753wr1198')
      viewer = Embed::Viewer::Media.new(embed_request)
      render(MediaWithCompanionWindowsComponent.new(viewer:))
    end

    def with_public_video
      embed_request = Embed::Request.new(url: 'https://purl.stanford.edu/gt507vy5436')
      viewer = Embed::Viewer::Media.new(embed_request)
      render(MediaWithCompanionWindowsComponent.new(viewer:))
    end

    def with_stanford_only_video
      embed_request = Embed::Request.new(url: 'https://purl.stanford.edu/bb142ws0723')
      viewer = Embed::Viewer::Media.new(embed_request)
      render(MediaWithCompanionWindowsComponent.new(viewer:))
    end

    def with_embargo
      embed_request = Embed::Request.new(url: 'https://purl.stanford.edu/hy056tp9463')
      viewer = Embed::Viewer::Media.new(embed_request)
      render(MediaWithCompanionWindowsComponent.new(viewer:))
    end

    def with_lots_of_files
      embed_request = Embed::Request.new(url: 'https://purl.stanford.edu/wz015vw6759')
      viewer = Embed::Viewer::Media.new(embed_request)
      render(MediaWithCompanionWindowsComponent.new(viewer:))
    end
  end
end
