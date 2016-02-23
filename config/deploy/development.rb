set :home_directory, "/home/#{fetch(:user)}"
set :deploy_to, "#{fetch(:home_directory)}/#{fetch(:application)}"

set :bundle_without, %w(test).join(' ')

set :rails_env, 'development'
