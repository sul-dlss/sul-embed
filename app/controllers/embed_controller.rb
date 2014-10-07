class EmbedController < ApplicationController
  before_action :validate_request

  def get
  end

  def validate_request
    @embed_request ||= Embed::Request.new(params)
  end

  rescue_from Embed::Request::NoURLProvided do |e|
    render body: e.to_s, status: 400
  end

  rescue_from Embed::Request::InvalidURLScheme do |e|
    render body: e.to_s, status: 404
  end

  rescue_from Embed::Request::InvalidFormat do |e|
    render body: e.to_s, status: 501
  end
end
