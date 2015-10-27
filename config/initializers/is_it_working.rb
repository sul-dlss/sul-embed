Rails.configuration.middleware.use(IsItWorking::Handler) do |h|
  h.check :url, get: Settings.purl_url
  h.check :url, get: Settings.stacks_url
  h.check :url, get: Settings.geo_wms_url
end
