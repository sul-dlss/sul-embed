# frozen_string_literal: true

class CompanionWindowsComponent < ViewComponent::Base
  # @param [#purl_object] viewer
  # @param [String] stimulus_controller any extra stimulus controllers to initialize on the component.
  def initialize(viewer:, stimulus_controller: nil)
    @viewer = viewer
    @stimulus_controller = stimulus_controller
  end

  renders_one :header_button
  renders_one :body
  renders_one :dialog
  renders_one :drawer_button
  renders_one :drawer_content
  renders_one :authorization_messages

  attr_reader :viewer

  delegate :purl_object, to: :viewer
  delegate :downloadable_files, :druid, to: :purl_object

  def iiif_v3_manifest_url
    "#{Settings.purl_url}/#{druid}/iiif3/manifest"
  end

  def render_content_list_panel?
    # for PDF viewer, do not render the content panel if there is just one downloadable file in the object
    return false if viewer.instance_of?(::Embed::Viewer::PdfViewer) && downloadable_files.size == 1

    true
  end

  def requested_by_chromium?
    user_agent_str = request.headers['User-Agent']
    return true if user_agent_str.match(%r{Chrome/\d+}) || user_agent_str.match(%r{Edg/\d+})

    false
  end
end
