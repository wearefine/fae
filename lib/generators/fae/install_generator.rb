module Fae
  class InstallGenerator < Rails::Generators::Base
    source_root ::File.expand_path('../templates', __FILE__)
    class_option :namespace, type: :string, default: 'admin', desc: 'Sets the namespace of the generator'
    class_option :fine, type: :boolean, default: false, desc: 'Sets FINE\'s defaults'

    def install
      run 'bundle install'
      add_route
      # copy templates and generators
      copy_file ::File.expand_path(::File.join(__FILE__, "../templates/tasks/fae_tasks.rake")), "lib/tasks/fae_tasks.rake"
      add_fae_assets
      add_navigation_concern
      add_authorization_concern
      build_initializer
      build_judge_initializer
      add_settingslogic_files
      rake 'fae:install:migrations'
      rake 'db:migrate'
      rake 'fae:seed_db'
    end

  private

    def add_route
      inject_into_file "config/routes.rb", after: "routes.draw do\n" do <<-RUBY
\n  namespace :#{options.namespace} do
  end
  # mount Fae below your admin namespec
  mount Fae::Engine => '/#{options.namespace}'\n
RUBY
      end
    end

    def add_fae_assets
      copy_file ::File.expand_path(::File.join(__FILE__, '../templates/assets/fae.scss')), 'app/assets/stylesheets/fae.scss'
      copy_file ::File.expand_path(::File.join(__FILE__, '../templates/assets/fae.js')), 'app/assets/javascripts/fae.js'
    end

    def add_navigation_concern
      copy_file ::File.expand_path(::File.join(__FILE__, '../templates/models/concerns/navigation_concern.rb')), 'app/models/concerns/fae/navigation_concern.rb'
    end

    def add_authorization_concern
      copy_file ::File.expand_path(::File.join(__FILE__, '../templates/models/concerns/authorization_concern.rb')), 'app/models/concerns/fae/authorization_concern.rb'
    end

    def add_settingslogic_files
      copy_file ::File.expand_path(::File.join(__FILE__, '../templates/config/settings.yml')), 'config/settings.yml'
      copy_file ::File.expand_path(::File.join(__FILE__, '../templates/models/settings.rb')), 'app/models/settings.rb'
    end

    def build_initializer
      init_source = options.fine ? "../templates/initializers/fae_fine.rb" : "../templates/initializers/fae.rb"
      copy_file ::File.expand_path(::File.join(__FILE__, init_source)), "config/initializers/fae.rb"
      inject_into_file "config/initializers/fae.rb", after: "Fae.setup do |config|\n" do <<-RUBY
\n  config.devise_secret_key = '#{SecureRandom.hex(64)}'\n
RUBY
      end
    end

    def build_judge_initializer
      copy_file ::File.expand_path(::File.join(__FILE__, "../templates/initializers/judge.rb")), "config/initializers/judge.rb"
    end

  end
end