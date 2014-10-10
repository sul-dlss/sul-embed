module Embed
  class Viewer
    module CommonViewer
      def initialize(request)
        @request = request
        @purl_object = request.purl_object
      end

      def asset_path(file)
        ActionController::Base.helpers.asset_path(file)
      end

      def to_html
        header_html << body_html << footer_html
      end

      def header_html
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-header') do
            doc.text @purl_object.title
          end
        end.to_html
      end

      def footer_html
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-footer') do
            doc.a(href: @purl_object.purl_url) { doc.text @purl_object.purl_url }
          end
        end.to_html
      end
    end
  end
end
