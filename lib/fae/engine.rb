require 'devise'
module Fae
  # Rails 8 apps are generated with Propshaft, which can't run alongside the
  # Sprockets pipeline Fae's assets depend on. Checked on load so the error
  # surfaces before Sprockets complains about a missing manifest.js.
  def self.check_asset_pipeline!
    return unless defined?(::Propshaft)

    raise <<~MSG
      Fae requires Sprockets and can't run alongside Propshaft.
      Replace `gem "propshaft"` with `gem "sprockets-rails"` in your Gemfile and add app/assets/config/manifest.js.
      See https://github.com/wearefine/fae/blob/main/docs/quickstart-guide.md
    MSG
  end
  check_asset_pipeline!

  # Host apps add their own admin styles in app/assets/stylesheets/fae_custom.(css|scss),
  # which the layouts link after Fae's prebuilt stylesheet.
  def self.custom_stylesheet?
    Rails.root.glob('app/assets/stylesheets/fae_custom.*').any?
  end

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

    # Also checked here in case propshaft is required after fae-rails
    initializer 'fae.check_asset_pipeline' do
      Fae.check_asset_pipeline!
    end

    # Runs after importmap-rails adds the host's app/javascript so host files of the same name take precedence
    initializer 'fae.assets', after: 'importmap.assets' do |app|
      next unless app.config.respond_to?(:assets)

      app.config.assets.paths << root.join('app/javascript')
      app.config.assets.precompile += %w( fae/manifest.js fae_importmap_manifest.js )
      app.config.assets.precompile << 'fae_custom.css' if Fae.custom_stylesheet?
    end

    # Fae's stylesheet is prebuilt, so a host fae.scss is no longer compiled into it
    config.after_initialize do |app|
      if app.root.join('app/assets/stylesheets/fae.scss').exist? && !Fae.custom_stylesheet?
        Rails.logger.warn '[Fae] app/assets/stylesheets/fae.scss is no longer used. Move your admin styles to app/assets/stylesheets/fae_custom.css (see the v5 upgrade notes).'
      end
    end

    # Fae's admin uses its own importmap so it works regardless of how the host app bundles JS.
    # Host apps can add or override pins in config/fae_importmap.rb.
    initializer 'fae.importmap', after: 'importmap' do |app|
      Fae.importmap.draw(root.join('config/importmap.rb'))

      host_importmap = app.root.join('config/fae_importmap.rb')
      Fae.importmap.draw(host_importmap) if host_importmap.exist?

      if app.config.importmap.sweep_cache && app.config.reloading_enabled?
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
