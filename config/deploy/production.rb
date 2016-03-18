set :home_directory, "/opt/app/#{fetch(:user)}"
set :deploy_to, "#{fetch(:home_directory)}/#{fetch(:application)}"

# The only production server at the moment. A second will be added after the node is pupgraded
server 'embed-prod-b.stanford.edu', user: fetch(:user), roles: %w(web db app)

Capistrano::OneTimeKey.generate_one_time_key!

set :bundle_without, %w(development test).join(' ')

set :rails_env, 'production'
