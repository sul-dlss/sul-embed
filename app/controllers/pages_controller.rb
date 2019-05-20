# frozen_string_literal: true

unless Rails.env.production?
  class PagesController < ActionController::Base
    include HighVoltage::StaticPage
    layout false
  end
end
