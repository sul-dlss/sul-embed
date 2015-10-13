module Embed
  ##
  # Mixin to provide standardized convenience methods to make filesize's pretty
  module PrettyFilesize
    ##
    # Convert to a standardized pretty filesize
    def pretty_filesize(size)
      Filesize.from("#{to_kilobyte(size)} KB").pretty
    end

    ##
    # Covert Bytes to Kilobytes
    def to_kilobyte(size)
      size.to_f / 1000
    end
  end
end
