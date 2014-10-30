module Fae
  class InstallGenerator < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    def install
      run 'bundle install'
      route "mount Fae::Engine => '/admin'"
      # copy templates and generators
      copy_file File.expand_path(File.join(__FILE__, "../templates/tasks/fae_tasks.rake")), "lib/tasks/fae_tasks.rake"
      build_initializer
      rake 'fae:install:migrations'
      rake 'db:migrate'
      rake 'fae:seed_db'
    end

  private

    def build_initializer
      copy_file File.expand_path(File.join(__FILE__, "../templates/initializers/fae.rb")), "config/initializers/fae.rb"
      inject_into_file "config/initializers/fae.rb", after: "Fae.setup do |config|\n" do <<-RUBY
\n  config.devise_secret_key = '#{SecureRandom.hex(64)}'\n
RUBY
      end
    end

  end
end