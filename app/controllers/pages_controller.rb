# frozen_string_literal: true

class PagesController < ApplicationController
  include HighVoltage::StaticPage unless Rails.env.production?

  layout false
end
