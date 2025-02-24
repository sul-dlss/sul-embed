# frozen_string_literal: true

module CompanionWindows
  class FullscreenButtonComponent < ViewComponent::Base
    def render?
      # Currently the fullscreen api does not support fullscreen on WebView on iOS
      # https://developer.mozilla.org/en-US/docs/Web/API/Fullscreen_API#api.document.fullscreenenabled
      request.user_agent !~ /iPhone|iPad/
    end
  end
end
