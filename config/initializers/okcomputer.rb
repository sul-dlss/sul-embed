require 'okcomputer'

# /status for 'upness' (Rails app is responding), e.g. for load balancer
# /status/all to show all dependencies
# /status/<name-of-check> for a specific check (e.g. for nagios warning)
OkComputer.mount_at = 'status'
OkComputer.check_in_parallel = true
OkComputer::Registry.deregister 'database' # don't check (unused) ActiveRecord database conn

# REQUIRED checks, required to pass for /status/all
#  individual checks also avail at /status/<name-of-check>
OkComputer::Registry.register 'ruby_version', OkComputer::RubyVersionCheck.new
# TODO: add app version check when okcomputer works with cap 3 (see https://github.com/sportngin/okcomputer/pull/112)

# note that purl home page is very resource heavy
purl_url_to_check = "#{Settings.purl_url}/status"
OkComputer::Registry.register 'purl_url', OkComputer::HttpCheck.new(purl_url_to_check)
OkComputer::Registry.register 'stacks_url', OkComputer::HttpCheck.new(Settings.stacks_url)
OkComputer.make_optional ['stacks_url']

# ------------------------------------------------------------------------------

# NON-CRUCIAL (Optional) checks, avail at /status/<name-of-check>
#   - at individual endpoint, HTTP response code reflects the actual result
#   - in /status/all, these checks will display their result text, but will not affect HTTP response code
# if Settings.enable_media_viewer?
#   stream_url = "https://#{Settings.stream.url}"
#   OkComputer::Registry.register 'streaming_url', OkComputer::HttpCheck.new(stream_url)
#   OkComputer.make_optional ['streaming_url']
# end

OkComputer::Registry.register 'geo_web_services_url', OkComputer::HttpCheck.new(Settings.geo_wms_url)

# Geo objects use this to link out to Earthworks'
# check geo_external_url without the last part after the slash
geo_ext_url_pieces = Settings.geo_external_url.split('/')
url_to_check = geo_ext_url_pieces[0..-2].join('/')
OkComputer::Registry.register 'geo_external_url', OkComputer::HttpCheck.new(url_to_check)

OkComputer.make_optional %w(geo_web_services_url geo_external_url)
