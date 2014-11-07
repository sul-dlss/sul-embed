HighVoltage.configure do |config|
  config.routes = false
end unless Rails.env.production?
