# frozen_string_literal: true

module Embed
  module Viewer
    class WasSeed < CommonViewer
      def to_partial_path
        'embed/template/was_seed'
      end

      def self.supported_types
        [:"webarchive-seed"]
      end

      def thumbs_list
        Embed::WasSeedThumbs.new(@purl_object.druid).thumbs_list
      end

      def format_memento_datetime(memento_datetime)
        I18n.l(Date.parse(memento_datetime), format: :sul) unless memento_datetime.blank?
      end

      def external_url
        @purl_object.ng_xml.xpath('//dc:identifier', 'dc' => 'http://purl.org/dc/elements/1.1/').try(:text)
      end

      def external_url_text
        'View this in the Stanford Web Archive Portal'
      end

      def default_body_height
        260
      end

      def item_size
        [body_height - 60, body_height - 60]
      end

      def image_height
        item_size[0] - 24
      end
    end
  end
end
