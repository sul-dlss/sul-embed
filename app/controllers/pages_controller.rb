# frozen_string_literal: true

class PagesController < ActionController::Base
  include HighVoltage::StaticPage
  layout false
end unless Rails.env.production?
