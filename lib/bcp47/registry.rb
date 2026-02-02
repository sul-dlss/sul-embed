# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/inflections'
require 'faraday'

module Bcp47
  class Registry
    CODE_DELIMITER = '-'
    LABEL_DELIMITER = ', '

    def self.records
      @records ||= Parser.new(Rails.root.join(Settings.language_subtag_registry.path).read).records
    end

    def self.[](code)
      matching_records = records.select do |record|
        # Some subtags are expressed as ranges in the registry (using the Ruby .. syntax)
        if record&.code&.match?('\.\.')
          Range.new(*record.code.split('..')).cover?(code)
        else
          record.code == code
        end
      end

      # If there are multiple records, return them as an array. Else return as a record.
      return matching_records.first if matching_records.size == 1

      matching_records
    end

    def self.file_date
      records.find(&:file_date).file_date
    end

    def self.resolve(string) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      string
        .split(CODE_DELIMITER)
        .filter_map
        .with_index do |record_code, index|
        # NOTE: The first segment is examined as is. Other segments are
        #       case-normalized, so that a lookup on e.g. "en-us" can find the
        #       language "en" with the region "US", or so that "zh-hant" finds
        #       the language "zh" with the script "Hant".
        record = if index.zero?
                   self[record_code]
                 elsif record_code.length == 2
                   self[record_code.upcase]
                 elsif record_code.length == 4
                   self[record_code.capitalize]
                 else # rubocop:disable Lint/DuplicateBranch
                   self[record_code]
                 end

        next if record.empty?

        record.label
      end
        .join(LABEL_DELIMITER)
        .presence
    end
  end
end
