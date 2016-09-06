require 'embed/media_tag'
module Embed
  class Viewer
    class Media < CommonViewer
      def body_html
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(
            class: 'sul-embed-body sul-embed-media',
            'style' => "height: #{body_height}px",
            'data-sul-embed-theme' => asset_url('media.css').to_s
          ) do
            doc.cdata Embed::MediaTag.new(self).to_html
            doc.script { doc.text ";jQuery.getScript(\"#{asset_url('media.js')}\");" }
          end
        end.to_html
      end

      def download_html
        return '' if @request.hide_download?
        Embed::DownloadPanel.new do
          <<-HTML.strip_heredoc
            <div class='sul-embed-panel-body'>
              <ul class='sul-embed-download-list'>
                #{download_list_items}
              </ul>
            </div>
          HTML
        end.to_html
      end

      def metadata_html
        Embed::MetadataPanel.new(@purl_object) do
          media_accessibility_note
        end.to_html
      end

      def self.supported_types
        return [] unless ::Settings.enable_media_viewer?
        [:media]
      end

      def self.show_download?
        true
      end

      private

      def default_body_height
        400 - (header_height + footer_height)
      end

      def download_list_items
        @purl_object.contents.map do |resource|
          resource.files.map do |file|
            link_text = if resource.description.present?
                          resource.description
                        else
                          file.title
                        end
            file_size = "(#{pretty_filesize(file.size)})" if file.size
            <<-HTML.strip_heredoc
              <li>
                <a href='#{file_url(file.title)}' title='#{file.title}' target='_blank' rel='noopener noreferrer'>Download #{link_text}</a>
                #{restrictions_text_for_file(file)}
                #{file_size}
              </li>
            HTML
          end
        end.flatten.join
      end

      def media_accessibility_note
        return unless Settings.purl_feedback_email.present?
        <<-HTML.strip_heredoc
          <dt>Media accessibility</dt>
          <dd>
            A transcript may be available in the Download panel.<br />
            To request a transcript or other assistance with media in this viewer, please contact us at
            <a href="mailto:#{Settings.purl_feedback_email}">#{Settings.purl_feedback_email}</a>.
          </dd>
        HTML
      end
    end
  end
end

Embed.register_viewer(Embed::Viewer::Media) if Embed.respond_to?(:register_viewer)
