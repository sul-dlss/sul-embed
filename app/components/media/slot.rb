# frozen_string_literal: true

module Media
  # Everything the media viewer needs in order to place one resource on screen: the file it
  # holds, how that file is identified and labelled, where it sits in the content list, and
  # whether it is the resource the viewer opens on.
  #
  # The media, PDF and preview image components all draw into the same WrapperComponent, so
  # they pass this along rather than each forwarding the same seven arguments.
  Slot = Data.define(:file, :type, :file_uri, :thumbnail, :index, :size, :selected) do
    def selected?
      selected
    end
  end
end
