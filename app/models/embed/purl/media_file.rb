# frozen_string_literal: true

module Embed
  class Purl
    # Any file on a media object, may be a mp4 or a caption file.
    class MediaFile < ResourceFile
      attr_accessor :sdr_generated, :language
      alias sdr_generated? sdr_generated

      def label_or_filename
        return text_representation_label if caption? || transcript?

        super
      end

      def text_representation_label
        file_type = caption? ? 'captions' : 'transcript'
        "#{language_label} #{file_type}#{sdr_generated_text}"
      end

      def sdr_generated_text
        sdr_generated? ? ' (auto-generated)' : ''
      end

      def media_caption_label
        "#{language_label}#{sdr_generated_text}"
      end

      def language_label
        Bcp47::Registry.resolve(language_code) || 'Unknown'
      end

      def language_code
        language.presence || 'en'
      end
    end
  end
end
