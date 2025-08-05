# frozen_string_literal: true

module Media
  class WrapperComponent < ViewComponent::Base
    include Embed::StacksImage

    # @param [Embed::Purl::MediaFile] file
    # @param [String] type
    def initialize(file:, type:, resource_index:, thumbnail:, size:, purl_version: nil)
      @file = file
      @type = type
      @resource_index = resource_index
      @thumbnail = thumbnail
      @size = size
      @purl_version = purl_version
    end

    attr_reader :file, :resource_index, :size

    # TODO: stanford_only and location_restricted moved to the media tag,
    #       so they can be removed after we switch to the new component
    def call # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      tag.div(style: 'flex: 1 0 100%;',
              data: {
                controller: 'media-wrapper',
                media_wrapper_index_value: @resource_index,
                action: 'thumbnail-clicked@window->media-wrapper#toggleVisibility',
                stanford_only: @file.stanford_only?,
                location_restricted: @file.view_location_restricted?,
                file_label: @file.label_or_filename,
                file_uri:,
                media_tag_target: 'mediaWrapper',
                thumbnail_url: @thumbnail.presence,
                default_icon:
              },
              # When rendering this component, show only the first media wrapper component
              hidden: !@resource_index.zero?) do
        tag.div class: 'sul-embed-media-wrapper' do
          content +
            render(Media::PrevNextComponent.new(file:, resource_index:, size:))
        end
      end
    end

    # If the file is an image, transform to the IIIF full size url,
    # This allows the URL for the file to match the URL in the IIIF manifest
    def file_uri
      return @file.file_url(version: @purl_version) if @type != 'image'

      stacks_thumb_url(@file.druid, @file.filename, size: 'full')
    end

    # What class to put on the icon in the "Media content" sidebar when there is no thumbnail
    # Used in media_tag_controller.js
    def default_icon
      @type == 'audio' ? 'audio-thumbnail-icon' : 'video-thumbnail-icon'
    end
  end
end
