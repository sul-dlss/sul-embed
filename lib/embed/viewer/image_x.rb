module Embed
  class Viewer
    class ImageX < CommonViewer
      def initialize(*args)
        super
        header_tools_logic << :image_button_logic << :file_count_logic
      end

      # don't show the download file count for image viewer
      def self.show_download_count?
        false
      end

      def body_html
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-body sul-embed-image-x', 'data-sul-embed-theme' => asset_url('image_x.css')) do
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
        "#{Settings.purl_url}/#{@purl_object.druid}/iiif/manifest"
      end

      def metadata_html
        Embed::MetadataPanel.new(@purl_object) do
          iiif_drag_and_drop_icon
        end.to_html
      end

      private

      def iiif_drag_and_drop_icon
        <<-HTML
          <dt>International Image Interoperability Framework</dt>
          <dd>
            <a class='sul-embed-image-x-iiif-drag-and-drop-link' href='#{drag_and_drop_url}' target='_parent'>
              <img src="#{asset_url('iiif-drag-icon.png')}" />
            </a>
            <span class='sul-embed-iiif-instruction'>
              #{drag_and_drop_instruction_text} <a href='#{Settings.iiif_info_url}' target='_parent'>IIIF viewer</a>
            </span>
          </dd>
        HTML
      end

      def drag_and_drop_url
        purl_url = "#{Settings.purl_url}/#{@purl_object.druid}"
        "#{purl_url}?manifest=#{purl_url}/iiif/manifest"
      end

      def drag_and_drop_instruction_text
        return 'Drag icon to open these images in a' if many_images?
        'Drag icon to open this image in a'
      end

      def many_images?
        @purl_object.contents.many? do |resource|
          resource.type == 'image'
        end
      end

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
        Embed::EmbedThisPanel.new(druid: @purl_object.druid, height: height, width: width, request: @request, purl_object_title: @purl_object.title) do
          Nokogiri::HTML::Builder.new do |doc|
            doc.div(class: 'sul-embed-section') do
              checkbox_options = { type: 'checkbox', id: 'sul-embed-embed-download', 'data-embed-attr': 'hide_download' }
              checkbox_options[:checked] = 'true' unless @request.hide_download?
              doc.input(checkbox_options)
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
                        doc.a(target: '_blank', rel: 'noopener noreferrer', href: file_url(file.title), download: nil) do
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
