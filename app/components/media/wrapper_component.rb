# frozen_string_literal: true

module Media
  class WrapperComponent < ViewComponent::Base
    def initialize(file:, type:, resource_index:, thumbnail:, size:)
      @file = file
      @type = type
      @resource_index = resource_index
      @thumbnail = thumbnail
      @size = size
    end

    def lr_button(class:, disabled:, index:, label:)
      tag.button(arrow, class:, disabled:, aria: { label: },
                        data: { controller: 'prev-next',
                                prev_next_content_list_outlet: '#content-list',
                                action: 'click->prev-next#prevNextMedia',
                                prev_next_index_param: index })
    end

    def buttons
      lr_button(class: 'left-arrow', disabled: @resource_index.zero?, index: @resource_index - 1,
                label: 'Previous item') +
        lr_button(class: 'right-arrow', disabled: @resource_index + 1 == @size, index: @resource_index + 1,
                  label: 'Next item')
    end

    def prev_next_container
      tag.div class: 'prev-next-container' do
        tag.div(class: 'prev-next-buttons') do
          buttons
        end +
          tag.div(id: 'current-title') do
            tag.span("#{@resource_index + 1} of #{@size} • #{@file.label_or_filename}")
          end
      end
    end

    def arrow
      tag.svg(viewBox: '0 0 24 24') do
        tag.path(d: 'm10 16.5 6-4.5-6-4.5zM12 2C6.48 2 2 6.48 2 12s4.48 10
                      10 10 10-4.48 10-10S17.52 2 12 2m0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8')
      end
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
                thumbnail_url: @thumbnail.presence,
                default_icon:
              },
              # When rendering this component, show only the first media wrapper component
              hidden: !@resource_index.zero?) do
        tag.div class: 'sul-embed-media-wrapper' do
          content + prev_next_container
        end
      end
    end

    # What class to put on the icon in the "Media content" sidebar when there is no thumbnail
    # Used in media_tag_controller.js
    def default_icon
      @type == 'audio' ? 'sul-i-file-music-1' : 'sul-i-file-video-3'
    end
  end
end
