# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/blank'
require 'date'

module Bcp47
  class Record
    DATE_FIELDS = %w[Added File-Date].map(&:underscore).freeze
    KNOWN_FIELDS = %w[
      Added
      Comments
      Deprecated
      Description
      File-Date
      Macrolanguage
      Preferred-Value
      Prefix
      Scope
      Subtag
      Suppress-Script
      Tag
      Type
    ].map(&:underscore).freeze
    FIELD_PATTERN = /^(?<field_name>[A-Z][a-zA-Z-]+): (?<field_body>.*)$/
    FOLDED_LINE = "\n  "

    def self.parse(record_string)
      new(
        record_string
          .gsub(FOLDED_LINE, ' ')
          .split("\n")
          .filter_map { |line| FIELD_PATTERN.match(line)&.named_captures&.slice('field_name', 'field_body')&.values } # rubocop:disable Style/SafeNavigationChainLength
      )
    end

    # @param [Array<Array<String, String>>] attributes an array of key-value pairs, like
    #   a hash but in two-dimensional array form since some keys in the data can be repeated
    def initialize(attributes = [])
      attributes.each do |field, value|
        field = field&.underscore
        next unless KNOWN_FIELDS.include?(field)

        public_send(:"#{field}=", value)
      end
    end

    KNOWN_FIELDS.each do |field|
      define_method(field) do
        current_value = instance_variable_get(:"@#{field}")
        return current_value unless DATE_FIELDS.include?(field) && current_value.present?

        Date.parse(current_value)
      end

      define_method(:"#{field}=") do |new_value|
        case (current_value = public_send(field))
        when NilClass
          instance_variable_set(:"@#{field}", new_value)
        when String
          instance_variable_set(:"@#{field}", [current_value, new_value])
        when Array
          instance_variable_set(:"@#{field}", current_value << new_value)
        else
          warn("field #{field} has unexpected value type: #{new_value}")
        end
      end
    end

    def label
      Array(description).first
    end

    def code
      subtag.presence || tag.presence
    end

    def empty?
      KNOWN_FIELDS.none? { |field| public_send(field) }
    end
  end
end
