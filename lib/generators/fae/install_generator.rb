module Fae
  class InstallGenerator < Rails::Generators::Base
    def install
      run 'bundle install'
      route "mount Fae::Engine => '/admin'"
      # copy templates and generators
      # build fae initializer and generate key
      rake 'db:migrate'
      # seed db
    end
  end
end