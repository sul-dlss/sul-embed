Rails.configuration.middleware.use(IsItWorking::Handler) do |h|
  h.check :url, get: Settings.purl_url
  h.check :url, get: Settings.stacks_url
  h.check :url, get: Settings.geo_wms_url
  # check geo_external_url without the last part after the slash
  pieces = Settings.geo_external_url.split('/')
  h.check :url, get: pieces[0..-2].join('/')
  h.check :url, get: Settings.was_thumbs_url
end
