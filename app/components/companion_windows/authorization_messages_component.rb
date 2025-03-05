# frozen_string_literal: true

module CompanionWindows
  class AuthorizationMessagesComponent < ViewComponent::Base
    def initialize(available:)
      @available = available
    end

    def available?
      @available
    end

    # bindings to stimulus actions
    def authorization_actions
      %w[auth-denied@window->iiif-auth-restriction#displayMessage
         needs-login@window->iiif-auth-restriction#displayLoginPrompt
         auth-success@window->iiif-auth-restriction#hideLoginPrompt
         login-success@window->iiif-auth-restriction#showMessagePanel
         thumbnail-clicked@window->iiif-auth-restriction#clearLocationRestriction].join(' ')
    end
  end
end
