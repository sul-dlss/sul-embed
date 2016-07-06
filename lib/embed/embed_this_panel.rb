module Embed
  class EmbedThisPanel
    def initialize(druid:, height:, width:, purl_object_title:)
      @druid = druid
      @height = height
      @width = width
      @purl_object_title = purl_object_title
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
                  <input type='checkbox' id='sul-embed-embed-title' data-embed-attr='hide_title' checked=true />
                  <label for='sul-embed-embed-title'>
                    title
                    <span class='sul-embed-embed-title'> (#{purl_object_title})</span>
                  </label>
                </div>
                #{panel_content}
                <div class='sul-embed-section'>
                  <input type='checkbox' id='sul-embed-embed' data-embed-attr='hide_embed' checked=true />
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

    def self.iframe_html(druid:, height:, width:)
      width_style = if width
                      "#{width}px"
                    else
                      '100%'
                    end
      src = "#{Settings.embed_iframe_url}?url=#{Settings.purl_url}/#{druid}&maxheight=#{height}&maxwidth=#{width}"
      "<iframe src='#{src}' height='#{height}px' width='#{width_style}' frameborder='0' marginwidth='0' marginheight='0' scrolling='no' allowfullscreen />"
    end

    private

    attr_reader :druid, :height, :width, :purl_object_title, :panel_content

    def iframe_html
      self.class.iframe_html(druid: druid, height: height, width: width)
    end
  end
end
