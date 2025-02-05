# frozen_string_literal: true

module Media
  class WrapperComponent < ViewComponent::Base
    def initialize(file:, type:, resource_index:, thumbnail:)
      @file = file
      @type = type
      @resource_index = resource_index
      @thumbnail = thumbnail
    end

    # TODO: stanford_only and location_restricted moved to the media tag,
    #       so they can be removed after we switch to the new component
    def call # rubocop:disable Metrics/MethodLength
      tag.div(style: 'flex: 1 0 100%;',
              data: {
                controller: 'media-wrapper',
                media_wrapper_index_value: @resource_index,
                action: 'thumbnail-clicked@window->media-wrapper#toggleVisibility',
                stanford_only: @file.stanford_only?,
                location_restricted: @file.location_restricted?,
                file_label: @file.label_or_filename,
                media_tag_target: 'mediaWrapper',
                thumbnail_url: @thumbnail.presence
              },
              # When rendering this component, show only the first media wrapper component
              hidden: !@resource_index.zero?) do
        tag.div class: 'sul-embed-media-wrapper' do
          content
        end
      end
    end
  end
end
