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

task default: [:javascript_tests, :spec, :rubocop]

task asset_paths: [:environment] do
  puts Rails.application.config.assets.paths
end

task javascript_tests: [:environment] do
  system 'yarn test'
end
