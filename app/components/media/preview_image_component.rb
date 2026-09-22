# frozen_string_literal: true

module Media
  # Displays an image (e.g. photo of the media) for a media resource
  class PreviewImageComponent < ViewComponent::Base
    include Embed::StacksImage

    # @param [String] druid the object identifier
    # @param [Media::Slot] slot the resource this component draws
    def initialize(druid:, slot:)
      @druid = druid
      @slot = slot
    end

    attr_reader :druid, :slot

    delegate :file, :index, :selected?, to: :slot

    def call
      render WrapperComponent.new(slot:) do
        tag.div(class: 'osd', id: "openseadragon-#{index}",
                data: { controller: 'osd', osd_url_value:, osd_nav_images_value:,
                        index:, selected: selected?,
                        action: 'thumbnail-clicked@window->osd#initializeViewer' })
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
