# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  # should only be here when gem group development and test aren't installed
end

# remove default rspec task
task(:default).clear

task default: ['test:prepare', :javascript_tests, :spec, :rubocop]

task asset_paths: [:environment] do
  puts Rails.application.config.assets.paths
end

task javascript_tests: [:environment] do
  exit(1) unless system 'yarn test'
end

task :update_language_tags do
  File.open(Settings.language_subtag_registry.path, 'w') do |file|
    file.write(Faraday.get(Settings.language_subtag_registry.url).body)
  end
end
