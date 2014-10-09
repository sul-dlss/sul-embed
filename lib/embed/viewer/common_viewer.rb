module Embed
  class Viewer
    module CommonViewer
      def initialize(request)
        @request = request
        @purl_object = request.purl_object
      end

      def asset_url(file)
        "#{asset_host}#{ActionController::Base.helpers.asset_url(file)}"
      end

      def asset_host
        # We should use https but it's not enabled on our servers yet.
        "http://#{@request.rails_request.host_with_port}"
      end

      def stacks_url
        "#{Settings.stacks_url}/file/druid:#{@purl_object.druid}"
      end

      def to_html
        '<div class="sul-embed-container">' << header_html << body_html << footer_html << '</div>'
      end

      def header_html
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-header') do
            doc.span(class: 'sul-embed-header-title') do
              doc.text @purl_object.title
            end
          end
        end.to_html
      end

      def footer_html
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-footer') do
            doc.div(class: 'sul-embed-purl-link') do
              doc.img(class: 'sul-embed-rosette', src: asset_url('sul-rosette.png'))
              doc.a(href: @purl_object.purl_url) do
                doc.text @purl_object.purl_url
              end
            end
          end
        end.to_html
      end
    end
  end
end
