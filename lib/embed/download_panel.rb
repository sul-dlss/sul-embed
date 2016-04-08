module Embed
  class DownloadPanel
    def initialize(title: 'Download item', &block)
      @panel_title = title
      @panel_content = yield block
    end

    def to_html
      <<-HTML.strip_heredoc
        <div class='sul-embed-panel-container'>
          <div class='sul-embed-panel sul-embed-download-panel' style='display:none' aria-hidden='true'>
            <div class='sul-embed-panel-header'>
              <button class='sul-embed-close' data-sul-embed-toggle='sul-embed-download-panel'>
                <span aria-hidden='true'>&times;</span>
                <span class='sul-embed-sr-only'>Close</span>
              </button>
              <div class='sul-embed-panel-title'>
                #{panel_title}
                <span class='sul-embed-panel-item-label'></span>
              </div>
            </div>
            #{panel_content}
          </div>
        </div>
      HTML
    end

    private

    attr_reader :panel_title, :panel_content
  end
end
