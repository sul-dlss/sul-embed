# frozen_string_literal: true

class DownloadPanelComponent < ViewComponent::Base
  def initialize(title: 'Download item')
    @title = title
  end

  attr_reader :title
end
