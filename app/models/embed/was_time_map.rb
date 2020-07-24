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
      @timemap ||= Faraday.get(timemap_url).body.split(",\n").map do |item|
        MementoLine.from_line(item)
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
          datetime: items[2]&.remove(/^datetime="|"$/),
        )
      end
    end
  end
end
