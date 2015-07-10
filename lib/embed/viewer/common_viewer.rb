module Embed
  class Viewer
    class CommonViewer
      def initialize(request)
        @request = request
        @purl_object = request.purl_object
      end

      def asset_url(file)
        "#{asset_host}#{ActionController::Base.helpers.asset_url(file)}"
      end

      def asset_host
        if Rails.env.production?
          Settings.static_assets_base
        else
          "//#{@request.rails_request.host_with_port}"
        end
      end

      def stacks_url
        "#{Settings.stacks_url}/file/druid:#{@purl_object.druid}"
      end

      def height
        @request.maxheight || calculate_height
      end

      def width
        @request.maxwidth || default_width
      end

      def to_html
        "<div class='sul-embed-container' id='sul-embed-object' style='display:none; #{container_styles}'>" << header_html << body_html << metadata_html << embed_this_html << download_html << footer_html << '</div>'
      end

      def header_html
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-header') do
            render_header_tools(doc)
          end if display_header?
        end.to_html
      end

      def footer_html
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-footer') do
            doc.div(class: 'sul-embed-footer-toolbar') do
              unless @request.hide_metadata?
                doc.button(class: 'sul-embed-footer-tool sul-embed-btn sul-embed-btn-xs sul-embed-btn-default fa fa-info-circle', 'aria-expanded' => 'false', 'data-sul-embed-toggle' => 'sul-embed-metadata-panel')
              end
              unless @request.hide_embed_this?
                doc.button(class: 'sul-embed-footer-tool sul-embed-btn sul-embed-btn-xs sul-embed-btn-default fa fa-code', 'aria-expanded' => 'false', 'data-sul-embed-toggle' => 'sul-embed-embed-this-panel')
              end
              if self.is_a?(Embed::Viewer::Image) && !@request.hide_download?
                doc.button(class: 'sul-embed-footer-tool sul-embed-btn sul-embed-btn-xs sul-embed-btn-default fa fa-download', 'aria-expanded' => 'false', 'data-sul-embed-toggle' => 'sul-embed-download-panel')
              end
              if external_url.present?
               doc.a(class: 'sul-embed-footer-tool sul-embed-btn sul-embed-btn-xs sul-embed-btn-default fa fa-external-link', 
                     href: "#{external_url}")
              end
            end
            doc.div(class: 'sul-embed-purl-link') do
              doc.img(class: 'sul-embed-rosette', src: asset_url('sul-rosette.png'))
              doc.a(href: @purl_object.purl_url, target: "_top") do
                doc.text @purl_object.purl_url.gsub(/^http:\/\//, '')
              end
            end
          end
        end.to_html
      end

      def metadata_html
        unless @request.hide_metadata?
          Nokogiri::HTML::Builder.new do |doc|
            doc.div(class: 'sul-embed-panel-container') do
              doc.div(class: 'sul-embed-panel sul-embed-metadata-panel', style: 'display:none;', :'aria-hidden' => 'true') do
                doc.div(class: 'sul-embed-panel-header') do
                  doc.button(class: 'sul-embed-close', 'data-sul-embed-toggle' => 'sul-embed-metadata-panel') do
                    doc.span('aria-hidden' => true, class: 'fa fa-close') {}
                    doc.span(class: 'sul-embed-sr-only') { doc.text "Close" }
                  end
                  doc.div(class: 'sul-embed-panel-title') do
                    doc.text @purl_object.title
                  end
                end
                doc.div(class: 'sul-embed-panel-body') do
                  doc.dl do
                    if @purl_object.use_and_reproduction.present?
                      doc.dt { doc.text('Use and reproduction') }
                      doc.dd { doc.text(@purl_object.use_and_reproduction) }
                    end
                    if @purl_object.copyright.present?
                      doc.dt { doc.text('Copyright') }
                      doc.dd { doc.text(@purl_object.copyright) }
                    end
                    if @purl_object.license.present?
                      doc.dt { doc.text('License') }
                      doc.dd do
                        doc.span(class: "sul-embed-license-#{@purl_object.license[:machine]}")
                        doc.text(@purl_object.license[:human])
                      end
                    end
                  end
                end
              end
            end
          end.to_html
        else
          ''
        end
      end

      def embed_this_html
        unless @request.hide_embed_this?
          Nokogiri::HTML::Builder.new do |doc|
            doc.div(class: 'sul-embed-panel-container') do
              doc.div(class: 'sul-embed-panel sul-embed-embed-this-panel', style: 'display:none;', :'aria-hidden' => 'true') do
                doc.div(class: 'sul-embed-panel-header') do
                  doc.button(class: 'sul-embed-close', 'data-sul-embed-toggle' => 'sul-embed-embed-this-panel') do
                    doc.span('aria-hidden' => true, class: 'fa fa-close') {}
                    doc.span(class: 'sul-embed-sr-only') { doc.text "Close" }
                  end
                  doc.div(class: 'sul-embed-panel-title') do
                    doc.text "Embed"
                  end
                end
                doc.div(class: 'sul-embed-panel-body') do
                  doc.div(class: 'sul-embed-embed-this-form') do
                    doc.span(class: 'sul-embed-options-label') do
                      doc.text "Select options:"
                    end
                    doc.div(class: 'sul-embed-section sul-embed-embed-title-section') do
                      doc.input(type: 'checkbox', id: 'sul-embed-embed-title', :'data-embed-attr' => 'hide_title', checked: true)
                      doc.label(for: 'sul-embed-embed-title') do
                        doc.text("title")
                        if @purl_object.title.present?
                          doc.span(class: 'sul-embed-embed-title') do
                            doc.text(" (#{@purl_object.title})")
                          end
                        end
                      end
                    end
                    if self.is_a?(Embed::Viewer::File)
                      doc.div(class: 'sul-embed-section') do
                        doc.input(type: 'checkbox', id: 'sul-embed-embed-search', :'data-embed-attr' => 'hide_search', checked: true)
                        doc.label(for: 'sul-embed-embed-search') { doc.text("add search box") }
                        doc.label(for: 'sul-embed-min_files_to_search') do
                          doc.text(' for')
                          doc.input(type: 'text', id: 'sul-embed-min_files_to_search', :'data-embed-attr' => 'min_files_to_search', value: '10')
                          doc.text('or more files')
                        end
                      end
                    end
                    if self.is_a?(Embed::Viewer::Image)
                      doc.div(class: 'sul-embed-section') do
                        doc.input(type: 'checkbox', id: 'sul-embed-embed-download', :'data-embed-attr' => 'hide_download', checked: true)
                        doc.label(for: 'sul-embed-embed-download') { doc.text("download") }
                      end
                    end
                    doc.div(class: 'sul-embed-section') do
                      doc.input(type: 'checkbox', id: 'sul-embed-embed', :'data-embed-attr' => 'hide_embed', checked: true)
                      doc.label(for: 'sul-embed-embed') { doc.text("embed") }
                    end
                    doc.div do
                      doc.div(class: 'sul-embed-options-label') do
                        doc.label(for: 'sul-embed-iframe-code') { doc.text("Embed code:") }
                      end
                      doc.div(class: 'sul-embed-section') do
                        doc.textarea(id: 'sul-embed-iframe-code', 'data-behavior' => 'iframe-code', rows: 4) do
                          doc.text("<iframe src='#{Settings.embed_iframe_url}?url=#{Settings.purl_url}/#{@purl_object.druid}' height='#{height}px' width='#{width || height}px' frameborder='0' marginwidth='0' marginheight='0' scrolling='no' allowfullscreen></iframe>")
                        end
                      end
                    end
                  end
                end
              end
            end
          end.to_html
        else
          ''
        end
      end

      def download_html
        ''
      end

      def external_url
        nil
      end
      
      private

      def tooltip_text(file)
        if file.stanford_only?
          ["Available only to Stanford-affiliated patrons", @purl_object.embargo_release_date].compact.join(" until ")
        end
      end

      # Loops through all of the header tools logic methods
      # and calls the corresponding method that is the return value
      def render_header_tools(doc)
        header_tools_logic.each do |logic_method|
          if (tool = send(logic_method))
            send(tool, doc)
          end
        end
      end

      # Array of method containing symbols representing method names.
      # These methods should return false if the particular tool should not display,
      # otherwise it should return the method name that will return the HTML for the tool (given the Nokogiri document context).
      # See #header_title_logic and #header_title_html as examples.
      def header_tools_logic
        @header_tools_logic ||= [:header_title_logic]
      end

      def header_title_logic
        return false if @request.hide_title?
        :header_title_html
      end

      def header_title_html(doc)
        doc.span(class: 'sul-embed-header-title') do
          doc.text @purl_object.title
        end
      end

      def display_header?
        header_tools_logic.any? do |logic_method|
          send(logic_method)
        end
      end

      def container_styles
        if height_style.present? || width_style.present?
          "#{[height_style, width_style].compact.join(' ')}"
        end
      end
      def height_style
        "max-height:#{height}px;" if height
      end
      def width_style
        "max-width:#{width}px;" if width
      end
      def header_height
        return 0 unless display_header?
        if !header_tools_logic.include?(:header_title_logic)
          40
        else
          63
        end
      end
      # Set a specific height for the body. We need to subtract
      # the header and footer heights from the consumer
      # requested maxheight, otherwise we set a default
      # which can be set by the specific viewers.
      def body_height
        if @request.maxheight
          @request.maxheight.to_i - (header_height + footer_height)
        else
          default_body_height
        end
      end
      def footer_height
        30
      end
      def calculate_height
        return nil unless body_height
        body_height + header_height + footer_height
      end
      def default_width
        nil
      end
      def default_body_height
        nil
      end

      def file_count_logic
        :file_count_html
      end

      def file_count_html(doc)
        doc.h2(class: 'sul-embed-item-count', 'aria-live' => 'polite') {}
      end

    end
  end
end