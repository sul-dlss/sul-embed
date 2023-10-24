# frozen_string_literal: true

module Embed
  class MediaWrapperComponent < ViewComponent::Base
    def initialize(file:, file_index:, thumbnail:, scroll: false)
      @file = file
      @file_index = file_index
      @thumbnail = thumbnail
      @scroll = scroll
    end

    def call
      tag.div(style: "flex: 1 0 100%;#{' overflow-y: scroll' if @scroll}",
              data: {
                stanford_only: @file.stanford_only?,
                location_restricted: @file.location_restricted?,
                file_label: @file.label,
                slider_object: @file_index,
                thumbnail_url: @thumbnail,
                duration: @file.duration
              }) do
        tag.div class: 'sul-embed-media-wrapper' do
          content
        end
      end
    end
  end
end
