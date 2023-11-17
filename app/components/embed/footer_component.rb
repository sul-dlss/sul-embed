# frozen_string_literal: true

module Embed
  class FooterComponent < ViewComponent::Base
    def initialize(viewer:)
      @viewer = viewer
    end

    attr_reader :viewer

    def file_count
      @viewer.purl_object.downloadable_files.length
    end

    def download_file_label
      I18n.t :download_files, count: file_count
    end
  end
end
