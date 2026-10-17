# frozen_string_literal: true

module Media
  class TagComponent < ViewComponent::Base
    include Embed::StacksImage

    with_collection_parameter :resource
    SUPPORTED_MEDIA_TYPES = %i[audio video].freeze

    # @param [Purl::Resource] resource This resource is expected to have a primary file.
    # @param [#index] resource_iteration Information about what part of the collection we are in
    # @param [String] druid the object identifier
    # @param [Integer] selected_index the offset of the resource the viewer opens on
    # @param [Integer, nil] page the one-based page a PDF should open to
    def initialize(resource:, resource_iteration:, druid:, selected_index: 0, page: nil)
      @resource = resource
      @file = resource.primary_file
      @resource_iteration = resource_iteration
      @druid = druid
      @selected_index = selected_index
      @page = page
    end

    attr_reader :file, :druid, :page

    delegate :type, to: :@resource
    delegate :primary_file_url, to: :@resource

    # Whether this is the resource the viewer opens on
    def selected?
      @resource_iteration.index == @selected_index
    end

    def call
      return render player if audio_or_video?
      return render PdfComponent.new(slot: slot(thumbnail_url), page:) if file.pdf?

      # An image resource carries no separate thumbnail file; it is its own thumbnail
      render PreviewImageComponent.new(druid:, slot: slot(own_thumbnail_url))
    end

    def player
      PlayerComponent.new(resource: @resource, druid:, slot: slot(thumbnail_url))
    end

    def audio_or_video?
      SUPPORTED_MEDIA_TYPES.include?(type.to_sym)
    end

    # @param [String, nil] thumbnail the image the content list shows for this resource
    def slot(thumbnail)
      Slot.new(file:, type:, file_uri: primary_file_url, thumbnail:, selected: selected?,
               index: @resource_iteration.index, size: @resource_iteration.size)
    end

    # the 74,73 size accounts for the additional pixel size returned by the image server
    def thumbnail_url
      stacks_square_url(druid, @resource.thumbnail.title, size: '74,73') if @resource.thumbnail
    end

    def own_thumbnail_url
      stacks_square_url(druid, file.title, size: '74,73')
    end
  end
end
