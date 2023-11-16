# frozen_string_literal: true

# Access this preview at:
# http://localhost:3000/rails/view_components/embed/media_with_companion_windows_component/with_default_title

module Embed
  class MediaWithCompanionWindowsComponentPreview < ViewComponent::Preview
    def with_audio
      render_media_viewer_for(url: 'https://purl.stanford.edu/gj753wr1198')
    end

    def with_public_video
      render_media_viewer_for(url: 'https://purl.stanford.edu/gt507vy5436')
    end

    def with_stanford_only_video
      render_media_viewer_for(url: 'https://purl.stanford.edu/bb142ws0723')
    end

    def with_embargo
      render_media_viewer_for(url: 'https://purl.stanford.edu/hy056tp9463')
    end

    def with_lots_of_files
      render_media_viewer_for(url: 'https://purl.stanford.edu/wz015vw6759')
    end

    def with_multiple_captions
      render_media_viewer_for(url: 'https://purl.stanford.edu/dq301jn4140')
    end

    private

    def render_media_viewer_for(url:)
      embed_request = Embed::Request.new(url:)
      viewer = Embed::Viewer::Media.new(embed_request)
      render(MediaWithCompanionWindowsComponent.new(viewer:))
    end
  end
end
