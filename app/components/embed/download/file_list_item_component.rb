# frozen_string_literal: true

module Embed
  module Download
    class FileListItemComponent < ViewComponent::Base
      include Embed::PrettyFilesize
      def initialize(file_list_item:)
        @file = file_list_item
      end
      attr_reader :file

      def file_size
        "(#{pretty_filesize(file.size)})" if file.size
      end

      def url
        file.file_url(download: true)
      end
    end
  end
end
