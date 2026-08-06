Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot for better performance and memory savings.
  config.eager_load = true

  # Full error reports are disabled and caching is enabled.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensure static files built in deploy are served by Rails when enabled.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present? || ENV['RENDER'].present?

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Use a different logger for distributed setups.
  # config.log_tags = [:request_id]

  # Use default logging formatter so PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Log to STDOUT in container environments.
  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations in production.
  config.active_record.dump_schema_after_migration = false

  # Print deprecation notices to the log.
  config.active_support.deprecation = :notify

  logger           = ActiveSupport::Logger.new(STDOUT)
  logger.formatter = config.log_formatter
  config.logger    = ActiveSupport::TaggedLogging.new(logger)
end
