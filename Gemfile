source "https://rubygems.org"

ruby '~> 3.3.0'

# Declare your gem's dependencies in fae.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'

# Set the version of Rails for the dummy app
gem 'rails', '~> 8.1.0'

gem 'rake'

# Only used by `rake fae:js:build` to resolve the legacy JavaScript's requires. Never required at boot:
# gems such as graphiql-rails switch to Sprockets-only behavior when the constant is defined.
gem 'sprockets', '~> 4.2', require: false

group :test, :development do
  gem 'rspec-rails'
  gem 'pry'
end

group :test do
  gem 'webrick'
  gem 'factory_bot_rails'
  gem 'cuprite'
  gem 'capybara-screenshot'
  gem 'guard-rspec'
  gem 'shoulda-matchers', require: false
  gem 'yarjuf'
  gem 'database_cleaner'
  gem 'rails-controller-testing'
end

gem 'mysql2'
gem 'pg'
gem "puma", ">= 6.0"

gem "fog-aws"

# The dummy app can behave more like our typical apps
gem 'graphql'
gem 'graphiql-rails'
gem 'settingslogic'
