# frozen_string_literal: true

module Embed
  module Viewer
    class WasSeed < CommonViewer
      delegate :druid, to: :@purl_object

      def component
        WasSeedComponent
      end

      def importmap
        'webarchive'
      end

      def stylesheet
        'was_seed.css'
      end

      def capture_list
        return [] if archived_timemap_url.blank?

        @capture_list ||= Embed::WasTimeMap.new(archived_timemap_url).capture_list
      end

      def archived_timemap_url
        if archived_site_url.include?('/*/') # Not a valid timemap url
          archived_site_url.sub('/*/', '/timemap/')
        else
          Honeybadger.notify('WasSeed#archived_timemap_url is malformed',
                             context: { druid:, archived_site_url: })
          nil
        end
      end

      def shelved_thumb
        stacks_thumb_url(druid, @purl_object.contents.first.primary_file.title, size: '200,')
      end

      def format_memento_datetime(memento_datetime)
        I18n.l(Date.parse(memento_datetime), format: :sul_was_long) if memento_datetime.present?
      end

      def external_url
        @purl_object.archived_site_url
      end

      def external_url_text
        'View this in the Stanford Web Archive Portal'
      end

      def archived_site_url
        @purl_object.archived_site_url.tap do |url|
          Honeybadger.notify("WasSeed#archived_site_url blank for #{druid}") if url.blank?
        end
      end

      private

      def default_height
        return 340 if request.hide_title?

        420
      end
    end
  end
end
