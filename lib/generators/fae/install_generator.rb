module Fae
  class InstallGenerator < Rails::Generators::Base
    def install
      set_source

      run 'bundle install'
      route "mount Fae::Engine => '/admin'"
      # copy templates and generators
      copy_file File.expand_path(File.join(__FILE__, "../../../tasks/fae_tasks.rake")), "lib/tasks/fae_tasks.rake"
      # build fae initializer and generate key
      rake 'db:migrate'
      # seed db
    end

    private

    def set_source
      Fae::InstallGenerator.source_root(File.expand_path(File.join(File.dirname(__FILE__), '../../')))
    end
  end
end