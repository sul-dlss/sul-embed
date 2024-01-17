# frozen_string_literal: true

module Embed
  module Viewer
    class File < CommonViewer
      def component
        FileComponent
      end

      def importmap
        'file'
      end

      def height
        return default_height if @embed_request.maxheight.to_i > default_height

        super
      end

      def file_type_icon(mimetype)
        if Constants::FILE_ICON[mimetype].nil?
          'sul-i-file-new-1'
        else
          Constants::FILE_ICON[mimetype]
        end
      end

      def file_size_text(file_size)
        return pretty_filesize(file_size) unless file_size.zero?

        'Download'
      end

      def min_files_to_search
        (@embed_request.min_files_to_search || Settings.min_files_to_search_default).to_i
      end

      def display_file_search?
        @display_file_search ||= !@embed_request.hide_search? &&
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

      # Returns true or false whether the viewer should display the Download All
      # link. The limits were determined in testing and may need to be adjusted
      # based on experience with download performance and any changes in the
      # Stacks API. It returns false when there is just one file because the
      # file download link will suffice for that.
      def display_download_all?
        @purl_object.size < 10_737_418_240 &&
          @purl_object.downloadable_files.length > 1 &&
          @purl_object.downloadable_files.length < 3000
      end

      def any_stanford_only_files?
        @purl_object.all_resource_files.any?(&:stanford_only?)
      end

      def download_url
        "#{Settings.stacks_url}/object/#{@purl_object.druid}"
      end

      private

      def default_height
        [file_specific_height + embargo_message_height + header_height, min_height].max
      end

      def min_height
        189
      end

      def header_height
        return 68 unless embed_request.hide_title?
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
        items_to_account_for = [file_count, 4].min

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
