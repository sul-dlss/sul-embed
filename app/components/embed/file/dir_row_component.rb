# frozen_string_literal: true

module Embed
  module File
    class DirRowComponent < ViewComponent::Base
      def initialize(viewer:, dir:, pos_in_set: nil, set_size: nil, level: 0)
        @viewer = viewer
        @dir = dir
        @pos_in_set = pos_in_set
        @set_size = set_size
        @level = level
      end

      attr_reader :viewer, :dir, :pos_in_set, :set_size, :level

      delegate :title, :files, :dirs, to: :dir

      def child_set_size
        @child_set_size ||= dirs.size + files.size
      end

      def first_td_style
        "padding-left: #{(level - 1) * 3}ch;"
      end
    end
  end
end
