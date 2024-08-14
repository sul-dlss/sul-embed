# frozen_string_literal: true

# Override Rails provided converter to handle SI units.
class SizeConverter < ActiveSupport::NumberHelper::NumberToHumanSizeConverter
  private

  # Allows a base to be specified for the conversion
  # 1024 was the default and that produces gigibytes
  # 1000 produces gigabytes
  def base
    options[:base] || 1000
  end
end
