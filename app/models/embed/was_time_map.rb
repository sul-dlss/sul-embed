# frozen_string_literal: true

module Embed
  class WasTimeMap
    attr_reader :timemap_url

    def initialize(timemap_url)
      @timemap_url = timemap_url
    end

    def capture_list
      timemap.select(&:memento?)
    end

    def timemap
      @timemap ||=
        begin
          response = Faraday.get(timemap_url)
          raise ResourceNotAvailable unless response.success?

          response.body.split(",\n").map do |item|
            MementoLine.from_line(item)
          end
        rescue Faraday::ConnectionFailed, Faraday::TimeoutError
          raise ResourceNotAvailable
        rescue ResourceNotAvailable
          []
        end
    end

    class ResourceNotAvailable < StandardError
      def initialize(msg = 'The requested timemap was not available')
        super
      end
    end

    class MementoLine
      attr_reader :rel, :url, :datetime

      def initialize(url:, rel:, datetime: nil)
        @url = url
        @rel = rel
        @datetime = datetime
      end

      def memento?
        /memento/.match?(rel)
      end

      def self.from_line(line)
        items = line.strip.split('; ')
        new(
          url: items[0].remove(/^<|>$/),
          rel: items[1].remove(/^rel="|"$/),
          datetime: items[2]&.remove(/^datetime="|"$/)
        )
      end
    end
  end
end
