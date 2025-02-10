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

task default: ['test:prepare', :spec, :rubocop]

task asset_paths: [:environment] do
  puts Rails.application.config.assets.paths
end

task :update_language_tags do
  File.open(Settings.language_subtag_registry.path, 'w') do |file|
    file.write(Faraday.get(Settings.language_subtag_registry.url).body)
  end
end

task :stackify, [:bare_druid] => :environment do |_task, args|
  exit(1) unless Rails.env.development?

  bare_druid = args[:bare_druid]
  druid_path = DruidTools::StacksDruid.new(bare_druid, Settings.stacks_storage_root).path
  `mkdir -p #{druid_path}`
  Embed::Purl.find(bare_druid).downloadable_files.each do |resource_file|
    puts "Downloading #{resource_file.filename} to #{druid_path}/#{resource_file.filename}"
    `curl https://stacks.stanford.edu/file/#{bare_druid}/#{resource_file.filename} -o #{druid_path}/#{resource_file.filename}`
  end
end
