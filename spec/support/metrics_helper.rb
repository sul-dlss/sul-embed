# frozen_string_literal: true

# Helpers for working with events sent via ahoy.js

def event_with_properties(name, properties)
  a_hash_including({ 'name' => name, 'properties' => a_hash_including(properties) })
end

def view_with_properties(properties)
  event_with_properties('$view', properties)
end

def wait_for_event(name)
  Timeout.timeout(Capybara.default_max_wait_time) do
    loop until StubMetricsApi.last_event&.dig('name') == name
  end
end

def wait_for_view
  wait_for_event('$view')
end
