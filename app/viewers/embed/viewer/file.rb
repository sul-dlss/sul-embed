# frozen_string_literal: true

module Embed
  module Viewer
    class File < CommonViewer
      def to_partial_path
        'embed/template/file'
      end

      def height
        return default_height if @request.maxheight.to_i > default_height

        super
      end

      def file_type_icon(mimetype)
        if Constants::FILE_ICON[mimetype].nil?
          'sul-i-file-new-1'
        else
          Constants::FILE_ICON[mimetype]
        end
      end

      def self.supported_types
        [:file]
      end

      def file_size_text(file_size)
        return pretty_filesize(file_size) unless file_size.zero?

        'Download'
      end

      def min_files_to_search
        (@request.min_files_to_search || Settings.min_files_to_search_default).to_i
      end

      def display_file_search?
        @display_file_search ||= !@request.hide_search? &&
                                 @purl_object.contents.map(&:files).flatten.length >= min_files_to_search
      end

      ##
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

      def display_header?
        super || display_file_search?
      end

      private

      def default_height
        [file_specific_height + embargo_message_height + header_height, min_height].max
      end

      def min_height
        189
      end

      def header_height
        return 68 unless request.hide_title?
        return 40 if display_file_search?

        0
      end

      def embargo_message_height
        return 44 if purl_object.embargoed?

        0
      end

      # This is neccessary because the file viewer's height is meant to be dynamic,
      # however we need to specify the exact height of the containing iframe (which
      # will give us extra whitespace below the embed viewer unless we do this)
      # Each item is 67px tall w/ a base of 55px we determine heights by: (item count * 67px) + 55px
      def file_specific_height
        file_count = @purl_object.all_resource_files.count
        items_to_account_for = if file_count >= 4
                                 4
                               else
                                 file_count
                               end

        55 + (items_to_account_for * 67)
      end

      ##
      # Creates a pretty date for display
      # @return [String] date in dd-mon-year format
      def pretty_embargo_date
        sul_pretty_date(@purl_object.embargo_release_date)
      end
    end
  end
end
