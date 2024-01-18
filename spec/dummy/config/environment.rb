# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

ActiveRecord::Migrator.migrations_paths = '../spec/dummy/db/migrate'