# frozen_string_literal: true

class LockedStatusComponent < ViewComponent::Base
  def call
    tag.picture class: 'locked-status' do
      # The explicitly empty alt is preferred here, since this image merely adds visual decoration.
      image_tag 'locked-media-poster.svg', loading: 'lazy', alt: ''
    end
  end
end
