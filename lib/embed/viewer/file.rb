module Embed
  class Viewer
    class File
      include Embed::Viewer::CommonViewer

      def initialize(*args)
        super
        header_tools_logic << :file_search_logic
      end

      def self.default_viewer?
        true
      end

      def body_html
        file_count = 0
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-body sul-embed-file', 'style' => "max-height: #{body_height}px", 'data-sul-embed-theme' => "#{asset_url('file.css')}") do
            doc.div(class: 'sul-embed-file-list') do
              doc.ul(class: 'sul-embed-media-list') do
                file_list_html(@purl_object.contents, file_count, doc)
              end
            end
            doc.script { doc.text ";jQuery.getScript(\"#{asset_url('file.js')}\");" }
          end
        end.to_html
      end

      def file_type_icon(mimetype)
        if Constants::FILE_ICON[mimetype].nil?
          'fa-file-o'
        else
          Constants::FILE_ICON[mimetype]
        end
      end

      def pretty_filesize(size)
        Filesize.from("#{to_kilobyte(size)} KB").pretty
      end

      def to_kilobyte(size)
        size.to_f / 1000
      end

      def file_url(title)
        "#{stacks_url}/#{title}"
      end

      def default_body_height
        600
      end
      
      def file_list_html(contents, file_count, doc)
        if contents.count == 1
          doc.div('data-sul-embed-pdf' => contents.first.files.first.location ) { doc.canvas(id: 'sul-embed-pdf-canvas') }
          doc.script { doc.text ";jQuery.getScript(\"#{asset_url('pdfjs-dist/build/pdf.js')}\")" }
        else
          contents.each do |resource|
            resource.files.each do |file|
              doc.li(class: 'sul-embed-media') do
                doc.div(class: 'sul-embed-count pull-left') do
                  doc.text file_count += 1
                end
                doc.div(class: 'sul-embed-media-object pull-left') do
                  if file.previewable?
                    doc.img(class: 'sul-embed-square-image',src: "#{image_url(file)}_square")
                  else
                    doc.i(class: "fa fa-3x #{file_type_icon(file.mimetype)}")
                  end
                end
                doc.div(class: 'sul-embed-media-body') do
                  doc.div(class: "sul-embed-media-heading #{'stanford-only' if file_is_stanford_only?(file)}") do
                    doc.a(href: file_url(file.title), title: tooltip_text(file), 'data-sul-embed-tooltip' => file_is_stanford_only?(file)) do
                      doc.text file.title
                    end
                  end
                  doc.div(class: 'sul-embed-description') do
                    doc.text resource.description
                  end
                  doc.div(class: 'sul-embed-download') do
                    doc.i(class: 'fa fa-download')
                    doc.a(href: file_url(file.title), download: nil) do
                      doc.text pretty_filesize(file.size)
                    end
                  end
                  preview_file_toggle(file, doc)
                end
                preview_file_window(file, doc)
              end
            end
          end
        end
      end

      def preview_file_toggle(file, doc)
        if file.previewable?
          doc.span(class: 'sul-embed-preview-toggle', 'data-sul-embed-file-preview-toggle' => 'true') do
            doc.i(class: 'fa fa-toggle-right')
            doc.span(class: 'sul-embed-preview-text') do
              doc.a(href: '#', 'data-sul-embed-file-preview-toggle-text' => 'true') do
                doc.text('Preview')
              end
            end
          end
        end
      end
      def preview_file_window(file, doc)
        if file.previewable?
          doc.div(style: 'display: none;', class: 'sul-embed-preview', 'data-sul-embed-file-preview-window' => 'true') do
            doc.img(src: "#{image_url(file)}_thumb")
          end
        end
      end
      def image_url(file)
        "#{Settings.stacks_url}/image/#{@purl_object.druid}/#{file.title.gsub(/\.\w+$/, '')}"
      end
      def self.supported_types
        [:media]
      end

      private

      def tooltip_text(file)
        if file_is_stanford_only?(file)
          ["Available only to Stanford-affiliated patrons", @purl_object.embargo_release_date].compact.join(" until ")
        end
      end
      def file_is_stanford_only?(file)
        @purl_object.embargoed? || file.stanford_only?
      end
      def file_search_logic
        return false if @request.params[:hide_search] && @request.params[:hide_search] == 'true'
        :file_search_html
      end

      def file_search_html(doc)
        doc.div(class: 'sul-embed-header-tools') do
          doc.div(class: 'sul-embed-search') do
            doc.label(for: 'sul-embed-search-input', class: 'sul-embed-sr-only') { doc.text 'Search this list' }
            doc.input(class: 'sul-embed-search-input', id: 'sul-embed-search-input', placeholder: 'Search this list')
          end
        end
      end
    end
  end
end

Embed.register_viewer(Embed::Viewer::File) if Embed.respond_to?(:register_viewer)
