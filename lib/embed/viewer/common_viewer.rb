module Embed
  class Viewer
    module CommonViewer
      def initialize(request)
        @request = request
        @purl_object = request.purl_object
      end

      def asset_url(file)
        "#{asset_host}#{ActionController::Base.helpers.asset_url(file)}"
      end

      def asset_host
        # We should use https but it's not enabled on our servers yet.
        "http://#{@request.rails_request.host_with_port}"
      end

      def stacks_url
        "#{Settings.stacks_url}/file/druid:#{@purl_object.druid}"
      end

      def to_html
        '<div class="sul-embed-container" id="sul-embed-object" style="display:none;">' << header_html << body_html << metadata_html << footer_html << '</div>'
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
              doc.button(class: 'sul-embed-btn sul-embed-btn-xs sul-embed-btn-default fa fa-info-circle', 'data-toggle' => 'sul-embed-metadata-panel')
            end
            doc.div(class: 'sul-embed-purl-link') do
              doc.img(class: 'sul-embed-rosette', src: asset_url('sul-rosette.png'))
              doc.a(href: @purl_object.purl_url) do
                doc.text @purl_object.purl_url
              end
            end
          end
        end.to_html
      end

      def metadata_html
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-metadata-panel-container') do
            doc.div(class: 'sul-embed-metadata-panel', style: 'display:none;') do
              doc.div(class: 'sul-embed-metadata-header') do
                doc.button(class: 'sul-embed-close', 'data-toggle' => 'sul-embed-metadata-panel') do
                  doc.span('aria-hidden' => true, class: 'fa fa-close') {}
                  doc.span(class: 'sul-embed-sr-only') { doc.text "Close" }
                end
                doc.div(class: 'sul-embed-metadata-title') do
                  doc.text @purl_object.title
                end
              end
              doc.hr
              doc.div(class: 'sul-embed-metadata-body') do
                doc.div(class: 'sul-embed-metadata-section') do
                  doc.div(class: 'sul-embed-metadata-heading') do
                    doc.text 'Use and reproduction'
                  end
                  doc.text @purl_object.use_and_reproduction
                end
                doc.div(class: 'sul-embed-metadata-section') do
                  doc.div(class: 'sul-embed-metadata-heading') do
                    doc.text 'Copyright'
                  end
                  doc.text @purl_object.copyright
                end
              end
            end
          end
        end.to_html
      end

      private

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
    end
  end
end
