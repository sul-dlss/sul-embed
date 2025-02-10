# frozen_string_literal: true

module Download
  class FileListItemComponent < ViewComponent::Base
    include Embed::PrettyFilesize
    def initialize(file_list_item:, prefer_filename: false)
      @file = file_list_item
      @prefer_filename = prefer_filename
    end
    attr_reader :file

    def file_size
      "(#{pretty_filesize(file.size)})" if file.size
    end

    def url
      file.file_url(download: true)
    end

    def download_label
      return file.filename if @prefer_filename

      file.label_or_filename
    end
  end
end
