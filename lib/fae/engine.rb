require 'devise'
module Fae
  class Engine < ::Rails::Engine
    isolate_namespace Fae
    delegate :vite_ruby, to: :class

    # include libraries
    require 'simple_form'
    require 'remotipart'
    require 'jquery-rails'
    require 'jquery-ui-rails'
    require 'judge'
    require 'judge/simple_form'
    require 'acts_as_list'
    require 'slim'
    require 'kaminari'
    require 'fae/version'
    require "sprockets/railtie"
    require 'vite_rails'
    require 'inertia_rails'

    def self.vite_ruby
      @vite_ruby ||= ViteRuby.new(root: root)
    end

    # Expose compiled assets via Rack::Static when running in the host app.
    config.app_middleware.use(Rack::Static,
      urls: ["/#{ vite_ruby.config.public_output_dir }"],
      root: root.join(vite_ruby.config.public_dir)
    )

    initializer 'vite_rails_engine.proxy' do |app|
      if vite_ruby.run_proxy?
        app.middleware.insert_before 0, ViteRuby::DevServerProxy, ssl_verify_none: true, vite_ruby: vite_ruby
      end
    end

    initializer 'vite_rails_engine.logger' do
      config.after_initialize do
        vite_ruby.logger = Rails.logger
      end
    end

    
    config.eager_load_paths += %W(#{config.root}/app)

    config.to_prepare do
      # Require decorators from main application
      Dir.glob(Rails.root.join('app', 'decorators', '**', '*_decorator.rb')).each do |decorator|
        Rails.configuration.cache_classes ? require(decorator) : load(decorator)
      end

      ApplicationController.helper(ApplicationHelper)
    end

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
