# frozen_string_literal: true

unless Rails.env.production?
  class PagesController < ApplicationController
    include HighVoltage::StaticPage
    layout false
  end
end
