# frozen_string_literal: true

module Embed
  class Purl
    class ResourceDir
      def initialize(title, files, dirs)
        @title = title
        @files = files
        @dirs = dirs
      end

      attr_reader :title, :files, :dirs
    end
  end
end
