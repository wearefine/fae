set :application, 'fae'
set :repo_url, 'git@github.com:wearefine/fae.git'

set :scm, :git

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

# set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{ tmp/pids }

set :rvm_type, :system

set :keep_releases, 5

# variable for forked version of capistrano-rails
set :rails_path, 'spec/dummy'

server '54.164.40.189',
  user: 'fae',
  roles: %w{web app db},
  port: 8022,
  ssh_options: {
    forward_agent: true
  }

namespace :deploy do

  desc 'Symlink secrets.yml'
  task :symlink_secrets do
    on roles(:app) do
      execute "rm #{release_path}/spec/dummy/config/secrets.yml"
      execute "ln -s #{shared_path}/secrets.yml #{release_path}/spec/dummy/config/secrets.yml"
    end
  end

  after 'deploy:symlink:release', :symlink_dummy_files do
    on roles(:app) do
      %w(log tmp/cache tmp/sockets public/system public/assets).each do |path|
        execute "rm -rf #{release_path}/spec/dummy/#{path}"
        execute "ln -s #{shared_path}/#{path} #{release_path}/spec/dummy/#{path}"
      end
    end
  end

  after 'deploy:updating', 'deploy:symlink_secrets'
  after :finishing, 'deploy:cleanup'

end

namespace :fine do
  desc 'Restart Passenger by touching tmp/restart.txt (single restart owner)'
  task :restart_passenger do
    on roles(:app) do
      execute :mkdir, '-p', release_path.join(fetch(:rails_path), 'tmp')
      execute :touch, release_path.join(fetch(:rails_path), 'tmp/restart.txt')
    end
  end
end
after 'deploy:published', 'fine:restart_passenger'
