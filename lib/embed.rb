module Embed
  require 'embed/url_schemes'
  require 'embed/request'
  require 'embed/response'

  @@registered_viewers = []
  def self.register_viewer(viewer)
    @@registered_viewers << viewer
  end
  def self.registered_viewers
    @@registered_viewers
  end

end
