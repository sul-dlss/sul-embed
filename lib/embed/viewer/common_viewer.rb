require 'embed/download_panel'
require 'embed/embed_this_panel'
require 'embed/mimetypes'
require 'embed/pretty_filesize'

module Embed
  class Viewer
    class CommonViewer
      include Embed::Mimetypes
      include Embed::PrettyFilesize

      attr_reader :purl_object
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
        return unless display_header?
        <<-HTML.strip_heredoc
          <div class="sul-embed-header">#{render_header_tools}</div>
        HTML
      end

      def footer_html
        <<-HTML.strip_heredoc
          <div class="sul-embed-footer">
            <div class="sul-embed-footer-toolbar">
              #{open_metadata_panel_button}
              #{open_embed_panel}
              #{open_download_panel}
              #{link_external_url}
            </div>
          </div>
        HTML
      end

      def open_metadata_panel_button
        return if @request.hide_metadata?
        <<-HTML.strip_heredoc
          <button class="sul-embed-footer-tool sul-embed-btn sul-embed-btn-toolbar sul-embed-btn-default \
                         sul-i-infomation-circle, aria-expanded='false', aria-label='open metadata panel', \
                         data-sul-embed-toggle='sul-embed-metadata-panel'">
          </button>
        HTML
      end

      def open_embed_panel
        return if @request.hide_embed_this
        <<-HTML.strip_heredoc
          <button class="sul-embed-footer-tool sul-embed-btn sul-embed-btn-toolbar sul-embed-btn-default \
                         sul-i-share', aria-expanded='false' aria-label= 'open embed this panel', \
                         data-sul-embed-toggle='sul-embed-embed-this-panel'">
          </button>
        HTML
      end

      def open_download_panel
        return unless show_download?
        <<-HTML.strip_heredoc
          <button class="sul-embed-footer-tool sul-embed-btn sul-em 'bed-btn-toolbar sul-embed-btn-default \
                         sul-i-download-3, aria-expanded='false', aria-label='open download panel', \
                         data-sul-embed-toggle='sul-embed-download-panel'">
          </button>
          #{download_counter}
        HTML
      end

      def download_counter
        file_count = @purl_object.all_resource_files.length
        return if file_count <= 0
        <<-HTML.strip_heredoc
          <span class="sul-embed-footer-tool sul-embed-download-count aria-label='number of downloadable files'">
            #{file_count}
          </span>
        HTML
      end

      def metadata_html
        return if @request.hide_metadata
        <<-HTML.strip_heredoc
          <div class="sul-embed-panel-container">
            <div class="sul-embed-panel sul-embed-metadata-panel", style="display:none", aria-hidden="true">
              <div class="sul-embed-panel-header">
                <button class="sul-embed-close data-sul-embed-toggle=sul-embed-metadata-panel">
                  <span aria-hidden="true"><![CDATA[&times;]]></span>
                  <span class="sul-embed-sr-only">Close</span>
                </button>
                <div class="sul-embed-panel-title">#{@purl_object.title}</div>
              </div>
              <div class="sul-embed-panel-body">
                <dl>
                  <dt>Available online</dt>
                  <dd><a href="#{@purl_object.purl_url}" target="_top">#{@purl_object.purl_url.gsub(/^http:\/\//, '')}</a></dd>
                  #{use_and_reproduction}
                  #{copyright}
                  #{license}
                </dl>
              </div>
            </div>
          </div>
        HTML
      end

      def use_and_reproduction
        return unless @purl_object.use_and_reproduction.present?
        <<-HTML.strip_heredoc
          <dt>Use and reproduction</dt>
          <dd>#{@purl_object.use_and_reproduction}</dd>
        HTML
      end

      def copyright
        return unless @purl_object.copyright_present?
        <<-HTML.strip_heredoc
          <dt>Copyright</dt>
          <dd>#{@purl_object.copyright}</dd>
        HTML
      end

      def license
        <<-HTML.strip_heredoc
          <dt>License</dt>
          <dd><span class="sul-embed-license-#{@purl_object.license[:machine]}"</span>#{@purl_object.license[:human]}</dd>
        HTML
      end

      # subclasses that require special behaviors (e.g. file, image_x, media) should
      #  override this method, passing a block to EmbedThisPanel
      def embed_this_html
        return '' if @request.hide_embed_this?
        Embed::EmbedThisPanel.new(druid: @purl_object.druid, height: height, width: width, purl_object_title: @purl_object.title).to_html
      end

      def download_html
        ''
      end

      def external_url
        nil
      end

      ##
      # Creates a file url for stacks
      # @param [String] title
      # @return [String]
      def file_url(title)
        "#{stacks_url}/#{title}"
      end

      ##
      # Checks to see if an item is embargoed to the world
      # @param [Embed::PURL::Resource::ResourceFile]
      # @return [Boolean]
      def embargoed_to_world?(file)
        @purl_object.embargoed? && !file.stanford_only?
      end

      ##
      # Creates a pretty date in a standardized sul way
      # @param [String] date_string
      # @return [String]
      def sul_pretty_date(date_string)
        I18n.l(Date.parse(date_string), format: :sul) unless date_string.blank?
      end

      ##
      # Should the download toolbar be shown?
      # @return [Boolean]
      def show_download?
        self.class.show_download? && !@request.hide_download?
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

      def self.show_download?
        false
      end

      private

      def tooltip_text(file)
        return unless file.stanford_only?
        ['Available only to Stanford-affiliated patrons',
         sul_pretty_date(@purl_object.embargo_release_date)]
          .compact.join(' until ')
      end

      # Loops through all of the header tools logic methods
      # and calls the corresponding method that is the return value
      def render_header_tools
        header_tools_logic.each do |logic_method|
          if (tool = send(logic_method))
            send(tool)
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

      def header_title_html
        <<-HTML.strip_heredoc
          <span class="sul-embed-header-title">#{@purl_object.title}</span>
        HTML
      end

      def display_header?
        header_tools_logic.any? do |logic_method|
          send(logic_method)
        end
      end

      def container_styles
        return unless height_style.present? || width_style.present?
        [height_style, width_style].compact.join(' ').to_s
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
        "<div class='sul-embed-item-count', aria-live='polite'></div>"
      end
    end
  end
end
