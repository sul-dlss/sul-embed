module Embed
  require 'constants'
  require 'embed/url_schemes'
  require 'embed/request'
  require 'embed/response'

  mattr_accessor :registered_viewers do
    []
  end

  def self.register_viewer(viewer)
    raise DuplicateViewerRegistration if viewer_supported_type_already_registered?(viewer)
    registered_viewers << viewer
  end

  class << self
    private

    def viewer_supported_type_already_registered?(viewer)
      viewer.supported_types.any? do |supported_type|
        registered_viewers.any? do |registered_viewer|
          registered_viewer.supported_types.include?(supported_type)
        end
      end
    end
  end

  class DuplicateViewerRegistration < StandardError
    def initialize(msg = 'A viewer has registered a supported type that another viewer has already registered.')
      super
    end
  end
end
