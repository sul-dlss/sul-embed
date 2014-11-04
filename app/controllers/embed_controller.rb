class EmbedController < ApplicationController
  before_action :validate_request
  before_filter :allow_iframe, only: :iframe

  def get
    if @embed_request.format.to_sym == :xml
      render xml:  Embed::Response.new(@embed_request).embed_hash.to_xml(root: 'oembed')
    else
      render json: Embed::Response.new(@embed_request).embed_hash
    end
  end

  def iframe
    render html: "<html><head><script src='//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js'></script></head><body>#{Embed::Response.new(@embed_request).html}</body></html>".html_safe
  end

  def validate_request
    @embed_request ||= Embed::Request.new(params, request)
  end

  rescue_from Embed::Request::NoURLProvided do |e|
    render body: e.to_s, status: 400
  end

  rescue_from Embed::Request::InvalidURLScheme do |e|
    render body: e.to_s, status: 404
  end

  rescue_from Embed::PURL::ResourceNotAvailable do |e|
    render body: e.to_s, status: 404
  end

  rescue_from Embed::Request::InvalidFormat do |e|
    render body: e.to_s, status: 501
  end

  private

  def allow_iframe
    response.headers.delete('X-Frame-Options')
  end

end
