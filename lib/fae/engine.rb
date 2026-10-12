require 'devise'
module Fae
  class Engine < ::Rails::Engine
    isolate_namespace Fae

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
    require 'importmap-rails'
    require 'stimulus-rails'
    require 'devise-two-factor'
    require 'rqrcode'
    require 'openai'
    require 'settingslogic'

    config.eager_load_paths += %W(#{config.root}/app)

    # Runs after importmap-rails adds the host's app/javascript so host files of the same name take precedence
    initializer 'fae.assets', after: 'importmap.assets' do |app|
      next unless app.config.respond_to?(:assets)

      app.config.assets.paths << root.join('app/javascript')
      app.config.assets.precompile += %w( fae_importmap_manifest.js )
    end

    # Fae's admin uses its own importmap so it works regardless of how the host app bundles JS.
    # Host apps can add or override pins in config/fae_importmap.rb.
    initializer 'fae.importmap', after: 'importmap' do |app|
      Fae.importmap.draw(root.join('config/importmap.rb'))

      host_importmap = app.root.join('config/fae_importmap.rb')
      Fae.importmap.draw(host_importmap) if host_importmap.exist?

      reloading = app.config.respond_to?(:reloading_enabled?) ? app.config.reloading_enabled? : !app.config.cache_classes
      if app.config.importmap.sweep_cache && reloading
        Fae.importmap.cache_sweeper(watches: [root.join('app/javascript'), app.root.join('app/javascript')])

        ActiveSupport.on_load(:action_controller_base) do
          before_action { Fae.importmap.cache_sweeper.execute_if_updated }
        end
      end
    end

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

  mattr_accessor :importmap, default: Importmap::Map.new
end
