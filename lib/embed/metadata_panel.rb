module Embed
  ###
  # A class to render metadata panel content given a variable
  # title and content for different viewers to customize
  class MetadataPanel
    attr_reader :purl_object
    def initialize(purl_object, &block)
      @purl_object = purl_object
      @panel_content = yield block if block_given?
    end

    def to_html
      <<-HTML.strip_heredoc
        <div class='sul-embed-panel-container'>
          <div class='sul-embed-panel sul-embed-metadata-panel' style='display:none' aria-hidden='true'>
            <div class='sul-embed-panel-header'>
              <button class='sul-embed-close' data-sul-embed-toggle='sul-embed-metadata-panel'>
                <span aria-hidden='true'>&times;</span>
                <span class='sul-embed-sr-only'>Close</span>
              </button>
              <div class='sul-embed-panel-title'>
                #{purl_object.title}
              </div>
            </div>
            <div class='sul-embed-panel-body'>
              <dl>
                #{panel_content}

                <dt>Citation URL</dt>
                <dd>
                  <a href='#{purl_object.purl_url}' target='_top'>#{user_friendly_purl_url}</a>
                </dd>
                #{use_and_reproduction}
                #{copyright}
                #{license}
              </dl>
            </div>
          </div>
        </div>
      HTML
    end

    def user_friendly_purl_url
      purl_object.purl_url.gsub(%r{^https?://}, '')
    end

    def use_and_reproduction
      return unless purl_object.use_and_reproduction.present?

      <<-HTML
        <dt>Use and reproduction</dt>
        <dd>#{purl_object.use_and_reproduction}</dd>
      HTML
    end

    def copyright
      return unless purl_object.copyright.present?

      <<-HTML
        <dt>Copyright</dt>
        <dd>#{purl_object.copyright}</dd>
      HTML
    end

    def license
      return unless purl_object.license.present?

      <<-HTML
        <dt>License</dt>
        <dd>
          <span class='sul-embed-license-#{purl_object.license[:machine]}'></span>
          #{purl_object.license[:human]}
        </dd>
      HTML
    end

    private

    attr_reader :panel_content
  end
end
