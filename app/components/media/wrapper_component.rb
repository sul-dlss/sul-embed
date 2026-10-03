# frozen_string_literal: true

module Media
  class WrapperComponent < ViewComponent::Base
    # @param [Media::Slot] slot the resource this wrapper holds
    def initialize(slot:)
      @slot = slot
    end

    attr_reader :slot

    delegate :file, :type, :file_uri, :thumbnail, :index, :size, :selected?, to: :slot

    # TODO: stanford_only and location_restricted moved to the media tag,
    #       so they can be removed after we switch to the new component
    def call
      tag.div(style: 'flex: 1 0 100%;',
              data: wrapper_data,
              # Only the resource the viewer opens on starts out visible
              hidden: !selected?) do
        tag.div class: 'sul-embed-media-wrapper' do
          content +
            render(Media::PrevNextComponent.new(file:, resource_index: index, size:))
        end
      end
    end

    def wrapper_data # rubocop:disable Metrics/MethodLength
      {
        controller: 'media-wrapper',
        media_wrapper_index_value: index,
        action: 'thumbnail-clicked@window->media-wrapper#toggleVisibility',
        stanford_only: file.stanford_only?,
        location_restricted: file.view_location_restricted?,
        file_label: file.label_or_filename,
        file_uri:,
        media_tag_target: 'mediaWrapper',
        thumbnail_url: thumbnail.presence,
        default_icon:,
        selected: selected?
      }
    end

    # What class to put on the icon in the "Media content" sidebar when there is no thumbnail
    # Used in media_tag_controller.js
    def default_icon
      return 'pdf-thumbnail-icon' if file.pdf?

      type == 'audio' ? 'audio-thumbnail-icon' : 'video-thumbnail-icon'
    end
  end
end
