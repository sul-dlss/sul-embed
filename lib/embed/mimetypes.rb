module Embed
  module Mimetypes
    ##
    # Creates a pretty human readable mime type
    # @param [String] mimetype
    # @return [String]
    def pretty_mime(mimetype)
      PrettyMime.new(mimetype).prettify
    end

    ##
    # A quick best effort to create a short human readable mimetype
    class PrettyMime
      attr_reader :mimetype
      ##
      # @param [String] mimetype
      def initialize(mimetype)
        @mimetype = mimetype
      end

      ##
      # Make the mimetype pretty if it can be looked up
      # @return [String]
      def prettify
        if lookup.nil?
          @mimetype
        else
          lookup.to_s.delete(':')
        end
      end
      
      private
      def lookup
        @lookup ||= Mime::Type.lookup(mimetype).to_sym
      end
    end
  end
end
