# frozen_string_literal: true

module Embed
  ###
  # A module to be mixed into classes to generate
  # URLs to stacks images using the IIIF image API
  module StacksImage
    def stacks_thumb_url(druid, file_name, size: '!400,400')
      "#{stacks_image_url(druid, file_name)}/full/#{size}/0/default.jpg"
    end

    def stacks_square_url(druid, file_name, size: 100)
      "#{stacks_image_url(druid, file_name)}/square/#{size},#{size}/0/default.jpg"
    end

    def stacks_image_url(druid, file_name)
      "#{Settings.stacks_url}/image/iiif/#{druid}%2F#{normalized_stacks_image_file_name(file_name)}"
    end

    private

    def normalized_stacks_image_file_name(file_name)
      ERB::Util.url_encode(file_name.gsub(/\.\w+$/, ''))
    end
  end
end
