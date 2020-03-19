# This require is a workaround for toplevel constant
# See https://github.com/rails/rails/issues/6931
# fixed in https://github.com/ruby/ruby/commit/44a2576f798b07139adde2d279e48fdbe71a0148
require 'embed/viewer/file'
require 'embed/viewer/virtex_3d_viewer'
Embed.register_viewer(Embed::Viewer::File)
Embed.register_viewer(Embed::Viewer::Geo)
Embed.register_viewer(Settings.image_viewer.constantize)
Embed.register_viewer(Embed::Viewer::PDFViewer) if Settings.use_custom_pdf_viewer
Embed.register_viewer(Embed::Viewer::Virtex3DViewer) if Settings.use_custom_3d_viewer
Embed.register_viewer(Embed::Viewer::Media)
Embed.register_viewer(Embed::Viewer::WasSeed)
