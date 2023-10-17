# frozen_string_literal: true

module Embed
  class WasTimeMap
    attr_reader :timemap_connection

    def initialize(timemap_url)
      @timemap_connection = redirectable_connection(timemap_url)
    end

    def capture_list
      timemap.select(&:memento?)
    end

    def timemap
      @timemap ||=
        begin
          response = timemap_connection.get
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

    private

    def redirectable_connection(url)
      Faraday.new(url:) do |faraday|
        faraday.use Faraday::FollowRedirects::Middleware

        faraday.adapter Faraday.default_adapter
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
        rel.include?('memento')
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
