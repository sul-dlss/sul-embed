# frozen_string_literal: true

class DownloadAccessComponent < ViewComponent::Base
  def initialize(file:)
    @file = file
  end

  attr_reader :file
end
