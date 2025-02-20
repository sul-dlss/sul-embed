# frozen_string_literal: true

# This is only used by the PdfComponent
class LocationRestrictionComponent < ViewComponent::Base
  def initialize(location='')
    @location = location
  end
end
