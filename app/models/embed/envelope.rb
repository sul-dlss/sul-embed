module Embed
  class Envelope
    ##
    # @param [Nokogiri::XML::Element]
    def initialize(envelope)
      @envelope = envelope
    end

    ##
    # Creates a bounding box as a 2D Array if an envelope is present (eg.
    # [[min_lng, min_lat], [max_lng, max_lat]])
    # @return [Array]
    def to_bounding_box
      [[west, south], [east, north]] if @envelope.present?
    end

    private

    def lower_corner
      @envelope.xpath('//gml:lowerCorner', 'gml' => 'http://www.opengis.net/gml/3.2/').first.text.split(' ')
    end

    def upper_corner
      @envelope.xpath('//gml:upperCorner', 'gml' => 'http://www.opengis.net/gml/3.2/').first.text.split(' ')
    end

    def south
      lower_corner[0]
    end

    def west
      lower_corner[1]
    end

    def north
      upper_corner[0]
    end

    def east
      upper_corner[1]
    end
  end
end
