# frozen_string_literal: true

module CompanionWindows
  class AuthorizationMessagesComponent < ViewComponent::Base
    # bindings to stimulus actions
    def authorization_actions
      %w[auth-denied@window->iiif-auth-restriction#displayMessage
         needs-login@window->iiif-auth-restriction#displayLoginPrompt
         auth-success@window->iiif-auth-restriction#hideLoginPrompt
         show-message-panel@window->iiif-auth-restriction#showMessagePanel
         thumbnail-clicked@window->iiif-auth-restriction#clearRestrictedMessage].join(' ')
    end
  end
end
