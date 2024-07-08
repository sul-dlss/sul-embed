# frozen_string_literal: true

module Embed
  ##
  # Mixin to provide standardized convenience methods to make filesize's pretty
  module PrettyFilesize
    ##
    # Convert to a standardized pretty filesize
    # @param [String] size the file size in bytes
    # @return [String] a human readable representation in SI units
    def pretty_filesize(size)
      SizeConverter.new(size, { base: 1000, precision: 2, significant: false }).convert
    end
  end
end
