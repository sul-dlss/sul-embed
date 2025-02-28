# frozen_string_literal: true

module Embed
  module Viewer
    class File < CommonViewer
      def component
        new_viewer? ? FileComponent : ::Legacy::FileComponent
      end

      def importmap
        new_viewer? ? 'file' : 'legacy_file'
      end

      def stylesheet
        new_viewer? ? 'file' : 'legacy_file.css'
      end

      def height
        return super if new_viewer?
        return default_height if @embed_request.maxheight.to_i > default_height.to_i

        super
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

      private

      def default_height
        return super if new_viewer?

        value = [file_specific_height + embargo_message_height + header_height, min_height].max
        "#{value}px"
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
    end
  end
end
