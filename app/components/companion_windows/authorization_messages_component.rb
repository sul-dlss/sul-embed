# frozen_string_literal: true

module CompanionWindows
  class AuthorizationMessagesComponent < ViewComponent::Base
    # bindings to stimulus actions
    def authorization_actions
      %w[auth-denied@window->iiif-auth-restriction#displayMessage
         needs-login@window->iiif-auth-restriction#displayLoginPrompt
         auth-success@window->iiif-auth-restriction#resetMessages
         login-success@window->iiif-auth-restriction#showMessagePane].join(' ')
    end
  end
end
