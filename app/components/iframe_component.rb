# frozen_string_literal: true

class IframeComponent < ViewComponent::Base
  def initialize(viewer:, version: nil)
    @viewer = viewer
    @version = version
  end

  delegate :height, :width, :embed_request, :iframe_title, :purl_object, to: :@viewer
  delegate :druid, :version_id, to: :purl_object
  attr_reader :version

  def width_style
    width ? "#{width}px" : '100%'
  end

  def height_style
    embed_request.fullheight? ? '100%' : "#{height}px"
  end

  def src
    puts ">> embed_request.as_url_params: #{embed_request.as_url_params}"
    query_params = embed_request.as_url_params.merge(version ? { _v: version } : {}).to_query
    "http://localhost:3001/iframe?url=#{Settings.purl_url}/#{path_segments}&#{query_params}"
  end

  def path_segments
    segments = [druid]
    segments += ['version', version_id] if version_id
    segments.join('/')
  end

  def call
    tag.iframe(src:, height: height_style, width: width_style, title: iframe_title,
               frameborder: 0, marginwidth: 0, marginheight: 0, scrolling: 'no', allowfullscreen: true,
               allow: 'clipboard-write')
  end
end
