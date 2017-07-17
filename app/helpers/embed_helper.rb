module EmbedHelper
  def download_panel(title: 'Download item', &block)
    Embed::DownloadPanel.new(title: title) { capture(&block) }.to_html.html_safe
  end

  def embed_panel(**args, &block)
    panel = if block_given?
              Embed::EmbedThisPanel.new(args) { capture(&block) }
            else
              Embed::EmbedThisPanel.new(args)
            end
    panel.to_html.html_safe
  end
end
