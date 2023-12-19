# frozen_string_literal: true

##
# Construct the urls to the streaming
# server for a given file w/i an object
module Embed
  class StacksMediaStream
    include StacksImage

    MANIFEST_FILE = '/playlist.m3u8'

    def initialize(druid:, file:)
      @druid = druid
      @file = file
    end

    def to_playlist_url
      return unless file.title && streaming_file_prefix

      # Use the Stacks URL to "stream" media in dev, as we're circumventing the need for a streaming server
      return "#{Settings.stacks_url}/file/#{druid}/#{file.filename}" if Rails.env.development?

      "https://#{Settings.stream.url}/#{druid_tree}/#{streaming_url_file_segment}#{MANIFEST_FILE}"
    end

    private

    attr_reader :druid, :file

    def streaming_file_prefix
      Settings.streaming_prefix[file_extension]
    end

    def file_extension
      ::File.extname(file.title).delete('.')
    end

    def druid_tree
      @druid_tree ||= begin
        match = druid.match(/^([a-z]{2})(\d{3})([a-z]{2})(\d{4})$/i)
        ::File.join(match[1], match[2], match[3], match[4]) if match
      end
    end

    def streaming_url_file_segment
      "#{streaming_file_prefix}:#{file.title}"
    end
  end
end
