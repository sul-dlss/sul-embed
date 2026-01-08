set :application, 'embed'
set :repo_url, 'https://github.com/sul-dlss/sul-embed.git'
set :user, 'embed'

# Default branch is :master so we need to update to main
if ENV['DEPLOY']
  set :branch, 'main'
else
  ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
end

# Workaround for supporting propshaft
# https://github.com/capistrano/rails/issues/257
set :assets_manifests, -> {
    [release_path.join("public", fetch(:assets_prefix), '.manifest.json')]
}

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w(config/honeybadger.yml config/newrelic.yml)

# Default value for linked_dirs is []
set :linked_dirs, %w(config/settings log node_modules tmp/pids tmp/cache tmp/sockets vendor/bundle public/vite public/system)

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# honeybadger_env otherwise defaults to rails_env
set :honeybadger_env, fetch(:stage)

# See https://github.com/capistrano/bundler/pull/137
set :bundle_version, 4

# update shared_configs before restarting app
before 'deploy:restart', 'shared_configs:update'
