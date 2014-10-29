module Fae
  class InstallGenerator < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    def install
      # set_source

      run 'bundle install'
      route "mount Fae::Engine => '/admin'"
      # copy templates and generators
      copy_file File.expand_path(File.join(__FILE__, "../templates/tasks/fae_tasks.rake")), "lib/tasks/fae_tasks.rake"
      # build fae initializer and generate key
      rake 'fae:install:migrations'
      rake 'db:migrate'
      rake 'fae:seed_db'
    end

  end
end