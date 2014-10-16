module Fae
  class InstallGenerator < Rails::Generators::Base
    def install
      run 'bundle install'
      route "mount Fae::Engine => '/admin'"
      # copy templates and genreators
      rake 'db:migrate'
    end
  end
end