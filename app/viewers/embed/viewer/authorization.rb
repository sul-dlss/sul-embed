# frozen_string_literal: true

module Embed
  module Viewer
    class Authorization
      def initialize(purl_object)
        @purl_object = purl_object
      end

      delegate :embargo_release_date, to: :@purl_object

      def message
        return { type: 'embargo', message: embargo_message } if @purl_object.embargoed?

        if @purl_object.stanford_only_unrestricted?
          return { type: 'stanford',
                   message: I18n.t('restrictions.stanford_only_file') }
        end

        if @purl_object.location_restriction
          return { type: 'location-restricted',
                   message: I18n.t('restrictions.restricted_access', location: @purl_object.restricted_location) }
        end

        false
      end

      def any_stanford_only_files?
        @purl_object.all_resource_files.any?(&:stanford_only?)
      end

      ##
      # TODO: this method can become private after the legacy file viewer is retired
      # Creates an embargo message to be displayed, customized for stanford
      # only embargoed items
      # @return [String]
      def embargo_message
        message = []

        message << if @purl_object.stanford_only_unrestricted?
                     'Access is restricted to Stanford-affiliated patrons'
                   else
                     'Access is restricted'
                   end

        message << pretty_embargo_date
        message.compact.join(' until ')
      end

      private

      ##
      # Creates a pretty date for display
      # @return [String] date in dd-mon-year format
      def pretty_embargo_date
        I18n.l(Date.parse(embargo_release_date), format: :sul) if embargo_release_date
      end
    end
  end
end
