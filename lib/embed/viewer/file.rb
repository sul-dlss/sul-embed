module Embed
  class Viewer
    class File < CommonViewer
      def initialize(*args)
        super
        header_tools_logic << :file_count_logic << :file_search_logic
      end

      def self.default_viewer?
        true
      end

      def body_html
        file_count = 0
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-body sul-embed-file', 'style' => "max-height: #{body_height}px", 'data-sul-embed-theme' => asset_url('file.css').to_s) do
            doc.div(class: 'sul-embed-file-list') do
              if @purl_object.embargoed?
                doc.div(class: 'sul-embed-embargo-message') do
                  doc.text embargo_message
                end
              end
              doc.ul(class: 'sul-embed-media-list') do
                @purl_object.contents.each do |resource|
                  resource.files.each do |file|
                    doc.li(class: 'sul-embed-media') do
                      doc.div(class: 'sul-embed-count sul-embed-pull-left') do
                        doc.text file_count += 1
                      end
                      doc.div(class: 'sul-embed-media-object sul-embed-pull-left') do
                        if file.previewable?
                          doc.img(class: 'sul-embed-square-image', src: stacks_square_url(@purl_object.druid, file.title), alt: '')
                        else
                          doc.i(class: "sul-i-2x #{file_type_icon(file.mimetype)}")
                        end
                      end
                      doc.div(class: 'sul-embed-media-body') do
                        file_heading(doc, file)
                        doc.div(class: 'sul-embed-description') do
                          doc.text resource.description
                        end
                        doc.div(class: 'sul-embed-download') do
                          doc.i(class: 'sul-i-download-3')
                          file_download_link(doc, file, file_count)
                        end
                        preview_file_toggle(file, doc, file_count)
                      end
                      preview_file_window(file, doc)
                    end
                  end
                end
              end
            end
            doc.script { doc.text ";jQuery.getScript(\"#{asset_pack_path('file.js')}\");" }
          end
        end.to_html
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

      def preview_file_toggle(file, doc, file_count)
        if file.previewable?
          doc.span(class: 'sul-embed-preview-toggle', 'data-sul-embed-file-preview-toggle' => 'true') do
            doc.i(class: 'sul-i-arrow-right-8')
            doc.span(class: 'sul-embed-preview-text') do
              doc.a(href: '#', 'data-sul-embed-file-preview-toggle-text' => 'true', 'aria-expanded' => false) do
                doc.text('Preview')
                doc.span(class: 'sul-embed-sr-only') do
                  doc.text " item #{file_count}"
                end
              end
            end
          end
        end
      end

      def preview_file_window(file, doc)
        return unless file.previewable?
        doc.div(style: 'display: none;', class: 'sul-embed-preview', 'data-sul-embed-file-preview-window' => 'true', 'aria-hidden' => true) do
          doc.img(src: stacks_thumb_url(@purl_object.druid, file.title), alt: '')
        end
      end

      def self.supported_types
        [:file]
      end

      private

      ##
      # Creates an embargo message to be displayed, customized for stanford
      # only embargoed items
      # @return [String]
      def embargo_message
        message = ['Access is restricted', pretty_embargo_date]
        if @purl_object.stanford_only_unrestricted?
          message[0] << ' to Stanford-affiliated patrons'
        end
        message.compact.join(' until ')
      end

      ##
      # Creates a pretty date for display
      # @return [String] date in dd-mon-year format
      def pretty_embargo_date
        sul_pretty_date(@purl_object.embargo_release_date)
      end

      ##
      # Creates a download link for a file header area, based off of
      # availability/embargo of a file
      # @param [Nokogiri::HTML::Builder] doc
      # @param [Embed::PURL::Resource::ResourceFile] file
      # @return [Nokogiri::HTML::Builder]
      def file_heading(doc, file)
        if embargoed_to_world?(file)
          doc.span(class: 'sul-embed-disabled') do
            doc.text file.title
          end
        else
          doc.div(class: 'sul-embed-media-heading') do
            doc.a(
              href: file_url(file.title),
              title: tooltip_text(file),
              target: '_blank',
              rel: 'noopener noreferrer'
            ) { doc.text file.title }
            doc << " #{restrictions_text_for_file(file)}"
          end
        end
      end

      ##
      # Creates a download link based on a file's availability/embargo
      # @param [Nokogiri::HTML::Builder] doc
      # @param [Embed::PURL::Resource::ResourceFile] file
      # @param [FixNum] file_count
      # @return [Nokogiri::HTML::Builder]
      def file_download_link(doc, file, file_count)
        if embargoed_to_world?(file)
          doc.span(class: 'sul-embed-disabled') do
            doc.text pretty_filesize(file.size)
          end
        else
          doc.a(href: file_url(file.title), download: nil, target: '_blank', rel: 'noopener noreferrer') do
            doc.span(class: 'sul-embed-sr-only') do
              doc.text "Download item #{file_count}"
            end
            doc.text file_size_text(file.size)
          end
        end
      end

      def file_size_text(file_size)
        return pretty_filesize(file_size) unless file_size.blank?
        'Download'
      end

      def embed_this_html
        return '' if @request.hide_embed_this?
        Embed::EmbedThisPanel.new(druid: @purl_object.druid, height: height, width: width, request: @request, purl_object_title: @purl_object.title) do
          Nokogiri::HTML::Builder.new do |doc|
            doc.div(class: 'sul-embed-section') do
              checkbox_options = { type: 'checkbox', id: 'sul-embed-embed-search', 'data-embed-attr': 'hide_search' }
              checkbox_options[:checked] = 'checked' unless @request.hide_search?
              doc.input(checkbox_options)
              doc.label(for: 'sul-embed-embed-search') { doc.text('add search box') }
              doc.label(for: 'sul-embed-min_files_to_search') do
                doc.text(' for')
                doc.input(type: 'text', id: 'sul-embed-min_files_to_search', 'data-embed-attr': 'min_files_to_search', value: min_files_to_search)
                doc.text('or more files')
              end
            end
          end.to_html
        end.to_html
      end

      def file_search_logic
        return false unless display_file_search?
        :file_search_html
      end

      def display_file_search?
        @display_file_search ||= begin
          @request.params[:hide_search] != 'true' &&
          @purl_object.contents.map(&:files).flatten.length >= min_files_to_search
        end
      end

      def min_files_to_search
        (@request.min_files_to_search || 10).to_i
      end

      def file_search_html(doc)
        doc.div(class: 'sul-embed-search') do
          doc.label(for: 'sul-embed-search-input', class: 'sul-embed-sr-only') { doc.text 'Search this list' }
          doc.input(class: 'sul-embed-search-input', id: 'sul-embed-search-input', placeholder: 'Search this list')
        end
      end
    end
  end
end

Embed.register_viewer(Embed::Viewer::File) if Embed.respond_to?(:register_viewer)
