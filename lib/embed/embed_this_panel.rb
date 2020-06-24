# frozen_string_literal: true

module Embed
  class EmbedThisPanel
    def initialize(viewer:)
      @druid = viewer&.purl_object&.druid
      @height = viewer&.height
      @width = viewer&.width
      @request = viewer&.request
      @iframe_title = viewer&.iframe_title
      @purl_object_title = viewer&.purl_object&.title
      @panel_content = yield if block_given?
    end

    def to_html
      <<-HTML.strip_heredoc
        <div class='sul-embed-panel-container'>
          <div class='sul-embed-panel sul-embed-embed-this-panel' style='display:none' aria-hidden='true'>
            <div class='sul-embed-panel-header'>
              <button class='sul-embed-close' data-sul-embed-toggle='sul-embed-embed-this-panel'>
                <span aria-hidden='true'>&times;</span>
                <span class='sul-embed-sr-only'>Close</span>
              </button>
              <div class='sul-embed-panel-title'>Embed</div>
            </div>
            <div class='sul-embed-panel-body'>
              <div class='sul-embed-embed-this-form'>
                <span class='sul-embed-options-label'>Select options:</span>
                <div class='sul-embed-section sul-embed-embed-title-section'>
                  <input
                    type='checkbox'
                    id='sul-embed-embed-title'
                    data-embed-attr='hide_title'
                    #{'checked' unless request.hide_title?}
                  />
                  <label for='sul-embed-embed-title'>
                    title
                    <span class='sul-embed-embed-title'> (#{purl_object_title})</span>
                  </label>
                </div>
                #{panel_content}
                <div class='sul-embed-section'>
                  <input
                    type='checkbox'
                    id='sul-embed-embed'
                    data-embed-attr='hide_embed'
                    #{'checked' unless request.hide_embed_this?}
                  />
                  <label for='sul-embed-embed'>embed</label>
                </div>
                <div>
                  <div class='sul-embed-options-label'>
                    <label for='sul-embed-iframe-code'>Embed code:</label>
                  </div>
                  <div class='sul-embed-section'>
                    <textarea id='sul-embed-iframe-code' data-behavior='iframe-code' rows=4>#{iframe_html}</textarea>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      HTML
    end

    def self.iframe_html(druid:, height:, width:, request:, title: '', version: nil)
      width_style = if width
                      "#{width}px"
                    else
                      '100%'
                    end
      height_style = if request.fullheight?
                       '100%'
                     else
                       "#{height}px"
                     end
      query_params = request.as_url_params.merge(version ? { _v: version } : {}).to_query
      src = "#{Settings.embed_iframe_url}?url=#{Settings.purl_url}/#{druid}&#{query_params}"

      <<-IFRAME.strip_heredoc
        <iframe src="#{src}" height="#{height_style}" width="#{width_style}" title="#{title}" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" allowfullscreen />
      IFRAME
    end

    private

    attr_reader :druid, :height, :width, :request, :purl_object_title, :panel_content, :iframe_title

    def iframe_html
      self.class.iframe_html(druid: druid, height: height, width: width, request: request, title: iframe_title)
    end
  end
end
