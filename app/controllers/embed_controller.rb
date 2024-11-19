# frozen_string_literal: true

class EmbedController < ApplicationController
  append_view_path Rails.root.join('app/views/embed')

  # Importmap digest must be part of the etag.
  # See https://github.com/rails/importmap-rails#include-a-digest-of-the-import-map-in-your-etag
  etag { Rails.application.importmap.digest(resolver: helpers) if request.format&.html? }

  before_action :embed_request
  # before_action :set_cache, only: %i[iiif]
  before_action :fix_etag_header, only: %i[get iframe]
  before_action :allow_iframe, only: %i[iiif iframe]

  def get
    @embed_request.validate!

  # return unless stale?(last_modified: @embed_request.purl_object.last_modified, etag: @embed_request.purl_object.etag)

    if @embed_request.format.to_sym == :xml
      render xml: Embed::Response.new(@embed_request).embed_hash(self).to_xml(root: 'oembed')
    else
      render json: Embed::Response.new(@embed_request).embed_hash(self)
    end
  end

  def post
    @embed_request.validate!

    if @embed_request.format.to_sym == :xml
        render xml: Embed::Response.new(@embed_request).embed_hash(self).to_xml(root: 'oembed')
    else
        render json: Embed::Response.new(@embed_request).embed_hash(self)
    end
  end


  def iframe
    # Trigger purl object validation (will raise Embed::Purl::ResourceNotAvailable)
    @embed_request.validate!

    return unless stale?(last_modified: @embed_request.purl_object.last_modified, etag: @embed_request.purl_object.etag)

    @embed_response = Embed::Response.new(@embed_request)
    render 'iframe'
  end

  # Given a url to a manifest, render a mirador viewer.
  #  (e.g. /iiif?url=https://purl.stanford.edu/fr426cg9537/iiif/manifest)
  def iiif
    @embed_request.validate! url_scheme: false, format: false
  end

  def embed_request
    @embed_request ||= Embed::Request.new(linted_params)
  end

  # NOTE: Both of these errors are handled automatically by ActionDispatch::ExceptionWrapper
  # @raises [ActionController::ParameterMissing] if the url parameter is not provided
  # @raises [ActionController::BadRequest] if the url parameter is not permitted
  def linted_params
    url = params.require(:url)
    begin
      URI.parse(url)
    rescue URI::InvalidURIError
      raise ActionController::BadRequest
    end
    params.permit(:url, :maxwidth, :maxheight, :format, :fullheight, :new_component,
                  :hide_title, :hide_embed, :hide_download, :hide_search, :min_files_to_search,
                  :canvas_id, :canvas_index, :search, :suggested_search, :image_tools, :cdl_hold_record_id, :workspace_state)
  end

  rescue_from Embed::Request::NoURLProvided do |e|
    render body: e.to_s, status: :bad_request
  end

  rescue_from Embed::Purl::ResourceNotEmbeddable do |_e|
    render body: 'The requested PURL resource was not embeddable.', status: :bad_request
  end

  rescue_from Embed::Request::InvalidURLScheme do |e|
    render body: e.to_s, status: :not_found
  end

  rescue_from Embed::Purl::ResourceNotAvailable do |e|
    render body: e.to_s, status: :not_found
  end

  rescue_from Embed::Request::InvalidFormat do |e|
    render body: e.to_s, status: :unsupported_media_type
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

  def fix_etag_header
    # Apache adds -gzip to the etag header, which causes the request appear stale.
    request.headers['HTTP_IF_NONE_MATCH'].sub!('-gzip', '') if request.if_none_match
  end
end
