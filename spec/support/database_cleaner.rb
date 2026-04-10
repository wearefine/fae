# because Avdi Grimm said so
# http://devblog.avdi.org/2012/08/31/configuring-database_cleaner-with-rails-rspec-capybara-and-selenium/

RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    # Ensure the super admin role always exists - required by Fae::SetupController
    Fae::Role.find_or_create_by!(name: 'super admin')
  end

  config.before(:each) do |example|
    # Use truncation for JS tests since the browser runs in a separate thread
    # with a separate database connection that can't see uncommitted transactions
    if example.metadata[:js]
      DatabaseCleaner.strategy = :truncation, { except: %w[fae_roles] }
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end