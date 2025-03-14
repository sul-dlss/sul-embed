# frozen_string_literal: true

module Embed
  module File
    class AuthMessagesComponent < ViewComponent::Base
      def initialize(message:)
        @message = message
      end

      attr_reader :message

      def icon
        MESSAGE_ICONS[message[:type]]
      end

      MESSAGE_ICONS = { 'embargo' => Icons::LockClockComponent,
                        'stanford' => Icons::LockComponent,
                        'location-restricted' => Icons::LockGlobeComponent }.freeze

      def render?
        message.present?
      end
    end
  end
end
