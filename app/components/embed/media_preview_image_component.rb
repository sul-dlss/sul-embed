# frozen_string_literal: true

module Embed
  # Displays an image (e.g. photo of the media) for a media resource
  class MediaPreviewImageComponent < ViewComponent::Base
    include StacksImage

    # @param [String] druid the object identifier
    # @param [ResourceFile] file the file to display
    # @param [Integer] resource_index the offset of this resource in the purl
    # @param [String] type the type of resource (either audio or video), used to determine which icon to show
    def initialize(druid:, file:, resource_index:, type:)
      @druid = druid
      @file = file
      @resource_index = resource_index
      @type = type
    end

    attr_reader :resource_index, :druid, :file, :type

    def call
      # the 74,73 size accounts for the additional pixel size returned by the image server 
      thumb_url = stacks_square_url(druid, file.title, size: '74,73')
      render MediaWrapperComponent.new(thumbnail: thumb_url, file:, type:, resource_index:, scroll: true) do
        tag.div(class: 'osd', id: "openseadragon-#{resource_index}",
                data: { controller: 'osd', osd_url_value:, osd_nav_images_value: })
      end
    end

    def osd_url_value
      "#{stacks_image_url(druid, file.filename)}/info.json"
    end

    def osd_nav_images_value # rubocop:disable Metrics/MethodLength
      {
        zoomIn: {
          REST: asset_path('zoomin_rest.png'),
          GROUP: asset_path('zoomin_grouphover.png'),
          HOVER: asset_path('zoomin_hover.png'),
          DOWN: asset_path('zoomin_pressed.png')
        },
        zoomOut: {
          REST: asset_path('zoomout_rest.png'),
          GROUP: asset_path('zoomout_grouphover.png'),
          HOVER: asset_path('zoomout_hover.png'),
          DOWN: asset_path('zoomout_pressed.png')
        },
        home: {
          REST: asset_path('home_rest.png'),
          GROUP: asset_path('home_grouphover.png'),
          HOVER: asset_path('home_hover.png'),
          DOWN: asset_path('home_pressed.png')
        },
        fullpage: {
          REST: asset_path('fullpage_rest.png'),
          GROUP: asset_path('fullpage_grouphover.png'),
          HOVER: asset_path('fullpage_hover.png'),
          DOWN: asset_path('fullpage_pressed.png')
        }
      }
    end
  end
end
