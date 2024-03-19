require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)
require "fae-rails"

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.available_locales = [:en, :cs, :frca, :zh]

    config.action_controller.include_all_helpers = false

    config.active_record.legacy_connection_handling = false

    config.active_record.encryption.primary_key = ENV["PRIMARY_KEY"]
    config.active_record.encryption.deterministic_key = ENV["DETERMINISTIC_KEY"]
    config.active_record.encryption.key_derivation_salt = ENV["KEY_DERIVATION_SALT"]
  end
end

