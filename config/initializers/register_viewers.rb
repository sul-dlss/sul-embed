# This require is a workaround for toplevel constant
# See https://github.com/rails/rails/issues/6931
# fixed in https://github.com/ruby/ruby/commit/44a2576f798b07139adde2d279e48fdbe71a0148
require 'embed/viewer/file'
Embed.register_viewer(Embed::Viewer::File)
Embed.register_viewer(Embed::Viewer::Geo)
Embed.register_viewer(Embed::Viewer::ImageX)
Embed.register_viewer(Embed::Viewer::Media)
Embed.register_viewer(Embed::Viewer::WasSeed)
