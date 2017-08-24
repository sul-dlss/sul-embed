module Embed
  module Viewer
    class ImageX < CommonViewer
      # don't show the download file count for image viewer
      def self.show_download_count?
        false
      end

      def to_partial_path
        'embed/template/image_x'
      end

      def self.supported_types
        [:image, :manuscript, :map, :book]
      end

      def self.show_download?
        true
      end

      def manifest_json_url
        "#{Settings.purl_url}/#{@purl_object.druid}/iiif/manifest"
      end

      def drag_and_drop_instruction_text
        return 'Drag icon to open these images in a' if many_images?
        'Drag icon to open this image in a'
      end

      def drag_and_drop_url
        purl_url = "#{Settings.purl_url}/#{@purl_object.druid}"
        "#{purl_url}?manifest=#{purl_url}/iiif/manifest"
      end

      ##
      # Title to display for the full download
      def full_download_title(file)
        "Download \"#{truncate(@purl_object.title).tr('"', '\'')}\" " \
          "(as #{pretty_mime(file.mimetype)})"
      end

      private

      def many_images?
        @purl_object.contents.many? do |resource|
          resource.type == 'image'
        end
      end

      ##
      # Truncate a string
      # @param [String] str
      # @param [Integer] length
      def truncate(str, length = 20)
        if str && str.length > length
          str.slice(0, length - 1) + ' ...'
        else
          str
        end
      end

      ##
      # Sets the default body height
      def default_body_height
        420
      end

      ##
      # Overriding CommonViewer because the ImageX viewer also has other things
      # in the header, we need a larger height calculation.
      def header_height
        return 40 unless display_header?
        super
      end
    end
  end
end
