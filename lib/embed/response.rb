# frozen_string_literal: true

module Embed
  class Response
    attr_reader :request

    delegate :height, :width, to: :viewer

    # @param [Embed::Request] request
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

    def html(controller)
      @html ||= controller.render_to_string(
        IframeComponent.new(viewer:, version: Rails.root.mtime.to_i)
      )
    end

    def embed_hash(controller)
      {
        type:,
        version:,
        provider_name:,
        title:,
        height:,
        width:
      }.merge(html: html(controller))
    end

    def viewer
      @viewer ||= Embed::ViewerFactory.new(@request).viewer
    end
  end
end
