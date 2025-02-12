# frozen_string_literal: true

module Icons
  class DownloadComponent < ViewComponent::Base
    # We allow passing classes because the download shows up in a modal and the file table
    # we don't want to apply MuiSvgIcon-root or modal-component-icon to the table icon (file view)
    # and we special css for the table icon in the file view
    def initialize(classes: 'MuiSvgIcon-root modal-component-icon')
      @classes = classes
    end

    attr_reader :classes
  end
end
