# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'yarjuf'
require 'factory_girl_rails'
require 'database_cleaner'
require 'rspec/rails'
require 'shoulda/matchers'
require 'pry'

# File.dirname(__FILE__) used because Rails.root is the dummy app
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
# ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)
# ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|

  config.infer_spec_type_from_file_location!

  # Include named routes
  config.include Rails.application.routes.url_helpers

  # Use capybara-webkit as the JS driver
  Capybara.javascript_driver = :webkit

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.include FactoryGirl::Syntax::Methods
  FactoryGirl.definition_file_paths = [File.expand_path('../factories', __FILE__)]
  FactoryGirl.find_definitions

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Stop running tests on first caught fail, this is best used with config.order = "defined"
  # config.fail_fast = true

  # helpers for authentication
  config.include Devise::TestHelpers, type: :controller
  config.include Devise::TestHelpers, type: :view

end
