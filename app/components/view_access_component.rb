# frozen_string_literal: true

class ViewAccessComponent < ViewComponent::Base
  def initialize(file:)
    @file = file
  end

  attr_reader :file
end
