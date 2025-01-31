# frozen_string_literal: true

class ContentListComponent < ViewComponent::Base
  def initialize(viewer:)
    @viewer = viewer
  end

  attr_reader :viewer

  def heading
    t('content_list_heading', scope: viewer.i18n_path)
  end
end
