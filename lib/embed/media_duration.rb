# frozen_string_literal: true

module Embed
  class MediaDuration
    attr_reader :media_data_element, :iso8601_duration

    # @param media_data_element [Nokogiri::XML::Node] <videoData> or <audioData>
    #                                                 element from contentMetadata/resource/file
    def initialize(media_data_element)
      @media_data_element = media_data_element
    end

    def to_s
      raw_value = duration_raw_value if media_data_element
      begin
        return ISODuration.new(raw_value).to_s if raw_value
      rescue ISO8601::Errors::UnknownPattern
        Honeybadger.notify(
          "ResourceFile#media duration ISO8601::Errors::UnknownPattern: '#{raw_value}'"
        )
        nil
      end
      nil
    end

    private

    def duration_raw_value
      media_data_element.attributes['duration'].try(:text) if media_data_element
    end

    # to parse durations, since ActiveSupport::Duration doesn't get a parse method till rails 5
    class ISODuration < ISO8601::Duration
      def to_s
        return nil unless supported_duration?

        # build up a list of the fields we want to use for output string
        field_accumulator = []
        %i[years months days hours minutes seconds].each do |atom_type|
          atom_val = atoms[atom_type]
          # if we've already started accumulating fields, or this field is non-zero, add this field to the list.
          # if we've hit the minutes field, start accumulating no matter what, since we always want to show minutes
          # and seconds.
          field_accumulator << atom_val if !field_accumulator.empty? || atom_val.nonzero? || atom_type == :minutes
        end

        # zero pad any field after the first, join with colons (e.g., returns '1:02:03' for 'P0DT1H2M3S',
        # '2:03' for 'PT2M3S').
        field_accumulator.map.with_index do |atom_val, idx|
          idx.positive? ? atom_val.to_i.to_s.rjust(2, '0') : atom_val.to_i.to_s
        end.join ':'
      end

      private

      # reject nonsensical running times for media
      def supported_duration?
        errors = []
        errors << "#{self.class} does not support specifying durations in weeks" if atoms[:weeks].nonzero?
        errors << "#{self.class} does not support specifying negative durations" if atoms.values.any?(&:negative?)
        return true if errors.empty?

        errors.each { |e| Honeybadger.notify(e) }
        false
      end
    end
  end
end
