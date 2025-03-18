# frozen_string_literal: true

module Download
  class FileListItemComponent < ViewComponent::Base
    include Embed::PrettyFilesize
    def initialize(file_list_item:, prefer_filename: false, version: nil)
      @file = file_list_item
      @prefer_filename = prefer_filename
      @version = version
    end
    attr_reader :file, :version

    def file_size
      "(#{pretty_filesize(file.size)})" if file.size
    end

    def url
      file.file_url(download: true, version:)
    end

    def download_label
      return file.filename if @prefer_filename

      file.label_or_filename
    end
  end
end
