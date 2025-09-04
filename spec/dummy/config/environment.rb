# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

ActiveRecord::Migrator.migrations_paths = '../spec/dummy/db/migrate'

# Set the default host and port to be the same as Action Mailer.
Rails.application.default_url_options = Rails.application.config.action_mailer.default_url_options