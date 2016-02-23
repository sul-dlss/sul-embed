class ApplicationController < ActionController::API
  include Squash::Ruby::ControllerMethods
  enable_squash_client
end
