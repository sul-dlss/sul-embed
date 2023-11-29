# frozen_string_literal: true

require 'stringio'

module Bcp47
  class Parser
    attr_reader :input

    RECORD_SEPARATOR = '%%'

    def initialize(input)
      @input = input
    end

    def records
      @records ||= iterable_input.each_line(RECORD_SEPARATOR).map { |record_string| Record.parse(record_string) }
    rescue TypeError
      warn "input is not parseable: #{input}"
    end

    private

    def iterable_input
      StringIO.new(input)
    end
  end
end
