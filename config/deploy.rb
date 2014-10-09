set :application, 'fae.afinedevelopment.com'
set :repo_url, 'git@bitbucket.org:wearefine/fae.git'

set :scm, :git

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

# set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets public/system public/assets}

set :rvm_type, :system

set :keep_releases, 5

set :rails_path, 'spec/dummy'

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
      execute "ln -s #{shared_path}/secrets.yml #{release_path}/config/secrets.yml"
    end
  end

  # deploy:restart not firing, so I added this hack for now
  after 'deploy:symlink:release', :restart_hack do
    on roles(:app) do
      execute "ln -s #{shared_path}/restart.txt #{release_path}/tmp/restart.txt"
      execute :touch, release_path.join('tmp','restart.txt')
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

  after :finishing, 'deploy:cleanup'

end
