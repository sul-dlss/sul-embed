# frozen_string_literal: true

module CompanionWindows
  class AuthMessagesComponent < ViewComponent::Base
    def initialize(message:)
      @message = message
    end

    attr_reader :message

    def icon
      MESSAGE_ICONS[message[:type]]
    end

    MESSAGE_ICONS = { 'embargo' => Icons::LockClockComponent,
                      'stanford' => Icons::LockPersonComponent,
                      'location-restricted' => Icons::LockGlobeComponent }.freeze

    def render?
      message.present?
    end
  end
end
