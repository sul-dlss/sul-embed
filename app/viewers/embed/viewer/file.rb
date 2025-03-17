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

      def stylesheet
        'file'
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
    end
  end
end
