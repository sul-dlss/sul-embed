module Embed
  module StacksAuth
    def authentication_url(druid, file_name)
      attributes = { host: Settings.stacks_url, druid: druid, title: file_name }
      Settings.streaming.auth_url % attributes
    end
  end
end
