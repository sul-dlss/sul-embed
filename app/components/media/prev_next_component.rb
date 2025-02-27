# frozen_string_literal: true

module Media
  class PrevNextComponent < ViewComponent::Base
    # @param [Embed::Purl::MediaFile] file
    def initialize(file:, resource_index:, size:)
      @file = file
      @resource_index = resource_index
      @size = size
      super
    end

    def arrow
      tag.svg(viewBox: '0 0 24 24') do
        tag.path(d: 'm10 16.5 6-4.5-6-4.5zM12 2C6.48 2 2 6.48 2 12s4.48 10
                    10 10 10-4.48 10-10S17.52 2 12 2m0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8')
      end
    end
  end
end
