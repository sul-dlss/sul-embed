class EmbedController < ApplicationController
  before_action :validate_request
  before_action :set_cache
  before_action :allow_iframe, only: :iframe

  def get
    if @embed_request.format.to_sym == :xml
      render xml: Embed::Response.new(@embed_request).embed_hash.to_xml(root: 'oembed')
    else
      render json: Embed::Response.new(@embed_request).embed_hash
    end
  end

  def iframe
    render html: "<html><head><script src='//ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js'></script></head><body>#{Embed::Response.new(@embed_request).html}</body></html>".html_safe
  end

  def validate_request
    @embed_request ||= Embed::Request.new(params, request)
  end

  rescue_from Embed::Request::NoURLProvided do |e|
    render body: e.to_s, status: 400
  end

  rescue_from Embed::PURL::ResourceNotEmbeddable do |e|
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

  # Setting a flash method on the controller so that squash can properly report errors
  # Flash does not exsist natively in Rails-API and we don't need it.
  def flash
    {}
  end

  # Setting a cookies method on the controller so that squash can properly report errors
  # Cookies do not exsist natively in Rails-API and we don't need them.
  def cookies
    []
  end

  private

  def set_cache
    return unless Rails.env.production?
    request.session_options[:skip] = true
    response.headers['Cache-Control'] = "public, max-age=#{Settings.cache_life}"
  end

  def allow_iframe
    response.headers.delete('X-Frame-Options')
  end
end
