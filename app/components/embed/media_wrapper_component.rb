# frozen_string_literal: true

module Embed
  class MediaWrapperComponent < ViewComponent::Base
    def initialize(file:, type:, file_index:, thumbnail:, scroll: false)
      @file = file
      @type = type
      @file_index = file_index
      @thumbnail = thumbnail
      @scroll = scroll
    end

    # TODO: stanford_only and location_restricted moved to the media tag,
    #       so they can be removed after we switch to the new component
    def call # rubocop:disable Metrics/MethodLength
      tag.div(style: "flex: 1 0 100%;#{' overflow-y: scroll' if @scroll}",
              data: {
                stanford_only: @file.stanford_only?,
                location_restricted: @file.location_restricted?,
                file_label: @file.label,
                slider_object: @file_index,
                thumbnail_url: @thumbnail.presence,
                default_icon: @type == 'audio' ? 'sul-i-file-music-1' : 'sul-i-file-video-3',
                duration: @file.duration
              }) do
        tag.div class: 'sul-embed-media-wrapper' do
          content
        end
      end
    end
  end
end
