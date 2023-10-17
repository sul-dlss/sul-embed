# frozen_string_literal: true

module Embed
  class Response
    attr_reader :request

    delegate :height, :width, to: :viewer
    def initialize(request)
      @request = request
    end

    def type
      'rich'
    end

    def version
      '1.0'
    end

    def provider_name
      'SUL Embed Service'
    end

    def title
      @request.purl_object.title
    end

    def html
      @html ||= ActionController::Base.new.render_to_string(
        IframeComponent.new(viewer:, version: Rails.root.mtime.to_i)
      )
    end

    def embed_hash
      {
        type:,
        version:,
        provider_name:,
        title:,
        height:,
        width:,
        html:
      }
    end

    def viewer
      @viewer ||= Embed::ViewerFactory.new(@request).viewer
    end
  end
end
