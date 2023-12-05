# frozen_string_literal: true

module Embed
  module LegacyMedia
    class MediaWrapperComponent < ViewComponent::Base
      def initialize(file:, type:, resource_index:, thumbnail:, scroll: false)
        @file = file
        @type = type
        @resource_index = resource_index
        @thumbnail = thumbnail
        @scroll = scroll
      end

      def call # rubocop:disable Metrics/MethodLength
        tag.div(style: "flex: 1 0 100%;#{' overflow-y: scroll' if @scroll}",
                data: {
                  stanford_only: @file.stanford_only?,
                  location_restricted: @file.location_restricted?,
                  file_label: @file.label_or_filename,
                  slider_object: @resource_index,
                  thumbnail_url: @thumbnail.presence,
                  default_icon: @type == 'audio' ? 'sul-i-file-music-1' : 'sul-i-file-video-3'
                }) do
          tag.div class: 'sul-embed-media-wrapper' do
            content
          end
        end
      end
    end
  end
end
