Rails.application.config.after_initialize do
  Embed.register_viewer(Embed::Viewer::File)
  Embed.register_viewer(Embed::Viewer::Geo)
  Embed.register_viewer(Embed::Viewer::M3Viewer)
  Embed.register_viewer(Embed::Viewer::PdfViewer)
  Embed.register_viewer(Embed::Viewer::Virtex3dViewer)
  Embed.register_viewer(Embed::Viewer::Media)
  Embed.register_viewer(Embed::Viewer::WasSeed)
end
