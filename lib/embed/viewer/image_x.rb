module Embed
  class Viewer
    class ImageX < CommonViewer
      def initialize(*args)
        super
        header_tools_logic << :image_button_logic << :file_count_logic
      end

      def body_html
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-body sul-embed-image-x', 'data-sul-embed-theme' => asset_url('image_x.css').to_s) do
            doc.div(id: 'sul-embed-image-x', 'data-manifest-url' => manifest_json_url, 'data-world-restriction' => !@purl_object.world_unrestricted?) {}
            doc.script { doc.text ";jQuery.getScript(\"#{asset_url('image_x.js')}\");" }
          end
        end.to_html
      end

      def self.supported_types
        [:image, :manuscript, :map, :book]
      end

      def self.show_download?
        true
      end

      def manifest_json_url
        "#{Settings.purl_url}/#{@purl_object.druid}/iiif/manifest.json"
      end

      private

      def image_button_logic
        :image_button_html
      end

      def image_button_html(doc)
        doc.div(class: 'sul-embed-image-x-buttons') do
          doc.button(
            class: 'sul-embed-btn sul-embed-btn-default sul-embed-btn-toolbar' \
              ' sul-i-layout-none sul-embed-hidden',
            'data-sul-view-mode' => 'individuals',
            'aria-label' => 'switch to individuals mode'
          )
          doc.button(
            class: 'sul-embed-btn sul-embed-btn-default sul-embed-btn-toolbar' \
              ' sul-i-layout-4 sul-embed-hidden',
            'data-sul-view-mode' => 'paged',
            'aria-label' => 'switch to paged mode'
          )
          doc.button(
            class: 'sul-embed-btn sul-embed-btn-default sul-embed-bt' \
              'n-toolbar sul-i-view-module-1 sul-embed-hidden',
            'data-sul-view-perspective' => 'overview',
            'aria-label' => 'switch to overview perspective'
          )
          doc.button(
            class: 'sul-embed-btn sul-embed-btn-default sul-embed-bt' \
              'n-toolbar sul-i-expand-1 sul-embed-hidden',
            'data-sul-view-fullscreen' => 'fullscreen',
            'aria-label' => 'switch to fullscreen'
          )
        end
      end

      def embed_this_html
        return '' if @request.hide_embed_this?
        Embed::EmbedThisPanel.new(druid: @purl_object.druid, height: height, width: width, purl_object_title: @purl_object.title) do
          Nokogiri::HTML::Builder.new do |doc|
            doc.div(class: 'sul-embed-section') do
              doc.input(type: 'checkbox', id: 'sul-embed-embed-download', 'data-embed-attr': 'hide_download', checked: true)
              doc.label(for: 'sul-embed-embed-download') { doc.text('download') }
            end
          end.to_html
        end.to_html
      end

      def download_html
        return '' if @request.hide_download?
        Embed::DownloadPanel.new(title: 'Download image') do
          Nokogiri::HTML::Builder.new do |doc|
            doc.div(class: 'sul-embed-panel-body') do
              doc.ul(class: 'sul-embed-download-list') {}
              @purl_object.contents.each do |resource|
                next unless resource.type == 'object'
                doc.ul(class: 'sul-embed-download-list-full') do
                  resource.files.each do |file|
                    next if embargoed_to_world?(file)
                    doc.li do
                      doc.div(class: ('sul-embed-stanford-only' if file.stanford_only?).to_s) do
                        doc.a(href: file_url(file.title), download: nil) do
                          if file.size.blank?
                            doc.text full_download_title(file)
                          else
                            doc.text full_download_title(file) +
                                     " #{pretty_filesize(file.size)}"
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end.to_html
        end.to_html
      end

      ##
      # Title to display for the full download
      def full_download_title(file)
        "Download \"#{truncate(@purl_object.title).tr('"', '\'')}\" " \
          "(as #{pretty_mime(file.mimetype)})"
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
    end
  end
end

Embed.register_viewer(Embed::Viewer::ImageX) if Embed.respond_to?(:register_viewer)
