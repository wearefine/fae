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

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, shared_path.join('restart.txt')
    end
  end

  desc 'Symlink secrets.yml'
  task :symlink_secrets do
    on roles(:app) do
      execute "rm #{release_path}/spec/dummy/config/secrets.yml"
      execute "ln -s #{shared_path}/secrets.yml #{release_path}/spec/dummy/config/secrets.yml"
    end
  end

  # deploy:restart not firing, so I added this hack for now
  after 'deploy:symlink:release', :restart_hack do
    on roles(:app) do
      execute "ln -s #{shared_path}/restart.txt #{release_path}/spec/dummy/tmp/restart.txt"
      execute :touch, release_path.join('spec', 'dummy', 'tmp','restart.txt')
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

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after 'deploy:updating', 'deploy:symlink_secrets'
  after :finishing, 'deploy:cleanup'

end
