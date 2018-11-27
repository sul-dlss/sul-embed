# frozen_string_literal: true

module Embed
  module Viewer
    class File < CommonViewer
      def to_partial_path
        'embed/template/file'
      end

      def file_type_icon(mimetype)
        if Constants::FILE_ICON[mimetype].nil?
          'sul-i-file-new-1'
        else
          Constants::FILE_ICON[mimetype]
        end
      end

      def default_body_height
        file_specific_body_height - (header_height + footer_height)
      end

      # This is neccessary because the file viewer's height is meant to be dynamic,
      # however we need to specify the exact height of the containing iframe (which
      # will give us extra whitespace below the embed viewer unless we do this)
      def file_specific_body_height
        case @purl_object.all_resource_files.count
        when 1
          200
        when 2
          275
        when 3
          375
        else
          400
        end
      end

      def self.supported_types
        [:file]
      end

      def file_size_text(file_size)
        return pretty_filesize(file_size) unless file_size.blank?

        'Download'
      end

      def min_files_to_search
        (@request.min_files_to_search || 10).to_i
      end

      def display_file_search?
        @display_file_search ||= begin
          @request.params[:hide_search] != 'true' &&
          @purl_object.contents.map(&:files).flatten.length >= min_files_to_search
        end
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

      ##
      # Creates a pretty date for display
      # @return [String] date in dd-mon-year format
      def pretty_embargo_date
        sul_pretty_date(@purl_object.embargo_release_date)
      end
    end
  end
end
