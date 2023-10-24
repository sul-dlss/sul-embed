# frozen_string_literal: true

##
# A simple rack application to stub the
# Stacks authentication check endpoint
class StubAuthEndpoint
  cattr_accessor :response_json
  def call(env)
    self.class.set_success! if self.class.response_json.blank?
    [
      200,
      { 'content_type' => 'application/json' },
      ["#{callback(env)}(#{self.class.response_json.to_json})"]
    ]
  end

  def self.set_success!
    self.response_json = success_json
  end

  def self.set_location_restricted!
    self.response_json = location_restricted_json
  end

  def self.set_stanford!
    self.response_json = stanford_restricted_json
  end

  # This is kind of odd, but when it's success it's just a string, not an array.
  # This comes from https://github.com/sul-dlss/stacks/blob/62d7b6771f084f9620638713a4e91c66e0b48027/app/controllers/media_controller.rb#L49-L60
  def self.success_json
    { 'status' => 'success', 'token' => 'abc123' }
  end

  def self.location_restricted_json
    { 'status' => ['location_restricted'] }
  end

  def self.stanford_restricted_json
    {
      'status' => ['stanford_restricted'],
      'service' => {
        '@id' => 'https://login-endpoint.stanford.edu',
        'label' => 'Login to play.'
      }
    }
  end

  private

  def callback(env)
    env['QUERY_STRING'][/callback=(.*)&/, 1]
  end
end
