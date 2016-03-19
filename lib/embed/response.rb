module Embed
  class Response
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
      @html ||= viewer.to_html
    end

    def embed_hash
      { type: type,
        version: version,
        provider_name: provider_name,
        title: title,
        height: height,
        width: width,
        html: html
      }
    end

    private

      def viewer
        @viewer ||= Embed::Viewer.new(@request).viewer
      end
  end
end
