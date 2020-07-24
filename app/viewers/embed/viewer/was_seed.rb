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

      def capture_list
        Embed::WasTimeMap.new(archived_timemap_url).capture_list
      end

      def archived_site_url
        @purl_object.ng_xml.xpath(
          '//mods:url[@displayLabel="Archived website"]',
          'mods' => 'http://www.loc.gov/mods/v3'
        )&.text
      end

      def archived_timemap_url
        archived_site_url.sub('/*/', '/timemap/')
      end

      def thumbs_list
        Embed::WasSeedThumbs.new(@purl_object.druid).thumbs_list
      end

      def format_memento_datetime(memento_datetime)
        I18n.l(Date.parse(memento_datetime), format: :sul) if memento_datetime.present?
      end

      def external_url
        @purl_object.ng_xml.xpath('//dc:identifier', 'dc' => 'http://purl.org/dc/elements/1.1/').try(:text)
      end

      def external_url_text
        'View this in the Stanford Web Archive Portal'
      end

      private

      def default_height
        return 274 if request.hide_title?

        353
      end
    end
  end
end
