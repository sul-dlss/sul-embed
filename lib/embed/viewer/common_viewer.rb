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
        if display_header?
          react_component('EmbedHeader', { headerTools: display_header_tools, title: @purl_object.title }, prerender: true)
        else
          ''
        end
      end

      def footer_html
        data_options = {
          toolbarButtons: toolbar_buttons,
          purlUrl: @purl_object.purl_url,
          rosetteUrl: asset_url('sul-rosette.png')
        }
        react_component('EmbedFooter', data_options, prerender: true)
      end

      ##
      # Creates an array of toolbar buttons that should be displayed
      # @return[Array]
      def toolbar_buttons
        buttons = []
        buttons.push(:metadata) unless @request.hide_metadata?
        buttons.push(:embed_this) unless @request.hide_embed_this?
        buttons.push(:download) unless @request.hide_download? || !self.is_a?(Embed::Viewer::Image)
        buttons
      end

      def metadata_html
        if @request.hide_metadata?
          ''
        else
          react_component('EmbedPanel',
                          {
                            panelType: 'EmbedPanelMetadata',
                            panelClass: 'sul-embed-metadata-panel',
                            panelTitle: @purl_object.title,
                            title: @purl_object.title,
                            useAndReproduction: @purl_object.use_and_reproduction,
                            copyright: @purl_object.copyright,
                            license: @purl_object.license
                          },
                          prerender: true
                         )
        end
      end

      def embed_this_html
        unless @request.hide_embed_this?
          react_component('EmbedPanel',
                          {
                            panelType: 'EmbedPanelEmbedThis',
                            panelClass: 'sul-embed-embed-this-panel',
                            panelTitle: 'Embed',
                            embedIframeUrl: Settings.embed_iframe_url,
                            purlUrl: Settings.purl_url,
                            druid: @purl_object.druid,
                            height: height,
                            width: width || height,
                            viewerType: self.class.name,
                            title: @purl_object.title
                          },
                          prerender: true
                         )
        else
          ''
        end
      end

      def download_html
        ''
      end

      private

      def tooltip_text(file)
        if file.stanford_only?
          ["Available only to Stanford-affiliated patrons", @purl_object.embargo_release_date].compact.join(" until ")
        end
      end

      def display_header_tools
        display = []
        header_tools_logic.each do |logic_method|
          if (tool = send(logic_method))
            display.push send(tool)
          end
        end
        display
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

      def header_title_html
        'EmbedHeaderTitle'
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

      def file_count_html
        'EmbedHeaderFileCount'
      end

    end
  end
end
