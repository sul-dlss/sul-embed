Rails.configuration.middleware.use(IsItWorking::Handler) do |h|
  h.check :url, get: Settings.purl_url
  h.check :url, get: Settings.stacks_url

  h.check :non_crucial do |status|
    non_crucial_url_check(Settings.geo_wms_url, status, 'Geo viewer uses this')
  end

  h.check :non_crucial do |status|
    # check geo_external_url without the last part after the slash
    geo_ext_url_pieces = Settings.geo_external_url.split('/')
    url_to_check = geo_ext_url_pieces[0..-2].join('/')
    non_crucial_url_check(url_to_check, status, 'Geo objects use this to link out to Earthworks')
  end

  h.check :non_crucial do |status|
    non_crucial_url_check(Settings.was_thumbs_url, status, 'Web Archive Seeds use this to get thumbnail images')
  end
end

# even if url doesn't return 2xx or 304, return status 200 here
#  (for load-balancer check) but expose failure in message text (for nagios check and humans)
def non_crucial_url_check(url, return_status, info)
  non_crucial_status = IsItWorking::Status.new('')
  IsItWorking::UrlCheck.new(get: url).call(non_crucial_status)
  non_crucial_status.messages.each do |x|
    return_status.ok "#{'FAIL: ' unless x.ok?}#{x.message} (#{info})"
  end
end
