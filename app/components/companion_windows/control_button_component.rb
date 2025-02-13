# frozen_string_literal: true

module CompanionWindows
  class ControlButtonComponent < ViewComponent::Base
    def initialize(aria:, action:, controller: '', html_class: '', role: nil, data: {}, hidden: nil) # rubocop:disable Metrics/ParameterLists
      @aria = aria
      @data = {}
      @data[:controller] = [controller, 'tooltip'].compact_blank.join(' ')
      @data[:action] =
        "#{action} mouseenter->tooltip#show focus->tooltip#show mouseleave->tooltip#hide blur->tooltip#hide"
      @html_class = html_class
      @role = role
      @hidden = hidden
      super
    end

    attr_reader :data, :aria, :html_class, :role, :hidden

    def call
      tag.button(class: html_class, data:, aria:, role:, hidden:) do
        content
      end
    end
  end
end
