module Fae
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    class_option :namespace, type: :string, default: 'admin', desc: 'Sets the namespace of the generator'

    def install
      run 'bundle install'
      add_route
      # copy templates and generators
      copy_file File.expand_path(File.join(__FILE__, "../templates/tasks/fae_tasks.rake")), "lib/tasks/fae_tasks.rake"
      add_fae_assets
      add_nav_items_concern
      build_initializer
      build_judge_initializer
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
      copy_file File.expand_path(File.join(__FILE__, '../templates/assets/fae.scss')), 'app/assets/stylesheets/fae.scss'
      copy_file File.expand_path(File.join(__FILE__, '../templates/assets/fae.js')), 'app/assets/javascripts/fae.js'
    end

    def add_nav_items_concern
      copy_file File.expand_path(File.join(__FILE__, '../templates/controllers/concerns/nav_items.rb')), 'app/controllers/concerns/fae/nav_items.rb'
    end

    def build_initializer
      copy_file File.expand_path(File.join(__FILE__, "../templates/initializers/fae.rb")), "config/initializers/fae.rb"
      inject_into_file "config/initializers/fae.rb", after: "Fae.setup do |config|\n" do <<-RUBY
\n  config.devise_secret_key = '#{SecureRandom.hex(64)}'\n
RUBY
      end
    end

    def build_judge_initializer
      copy_file File.expand_path(File.join(__FILE__, "../templates/initializers/judge.rb")), "config/initializers/judge.rb"
    end

  end
end