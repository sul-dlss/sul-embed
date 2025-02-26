# frozen_string_literal: true

class CompanionWindowsComponent < ViewComponent::Base
  # @param [#purl_object] viewer
  # @param [String] stimulus_controller any extra stimulus controllers to initialize on the component.
  def initialize(viewer:, stimulus_controller: '')
    @viewer = viewer
    @stimulus_controller = stimulus_controller
  end

  renders_many :header_buttons
  renders_many :share_menu_buttons
  renders_one :body
  renders_one :dialog
  renders_one :drawer_button
  renders_one :drawer_content
  renders_one :authorization_messages

  attr_reader :viewer

  delegate :purl_object, :display_header?, to: :viewer
  delegate :downloadable_files, :druid, :title, :iiif_v3_manifest_url, to: :purl_object

  def media_viewer?
    viewer.instance_of?(::Embed::Viewer::Media)
  end

  def document_viewer?
    viewer.instance_of?(::Embed::Viewer::PdfViewer)
  end

  def render_content_list_panel?
    # for Document viewer, do not render the content panel if there is just one downloadable file in the object
    media_viewer? || (document_viewer? && downloadable_files.size > 1)
  end

  def display_download?
    !viewer.instance_of?(::Embed::Viewer::WasSeed)
  end

  def controllers
    "companion-window iiif-manifest-loader#{fullscreen? ? ' fullscreen ' : ' '}" + @stimulus_controller
  end

  def fullscreen?
    @fullscreen ||= request.user_agent !~ /#{Settings.fullscreen_hide}/
  end
end
