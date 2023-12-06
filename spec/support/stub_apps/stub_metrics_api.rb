# frozen_string_literal: true

# Stub for the SDR metrics API:
# https://github.com/sul-dlss/sdr-metrics-api
# rubocop:disable Style/ClassVars
class StubMetricsApi
  cattr_accessor :events

  @@events = []

  def self.last_event
    events.last
  end

  def self.reset!
    @@events = []
  end

  def call(env)
    req = Rack::Request.new(env)
    case req.path
    when %r{/visits$}
      track_visit
    when %r{/events$}
      track_events(req.params['events_json'])
    else
      [404, {}, ['Not Found']]
    end
  end

  def track_visit
    [200, {}, []]
  end

  def track_events(params)
    JSON.parse(params).each { |event| @@events << event }
    [200, {}, []]
  end
end
# rubocop:enable Style/ClassVars
