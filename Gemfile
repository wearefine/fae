source "https://rubygems.org"

ruby '3.1.1'

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
gem 'rails', '~> 7.0.2'

# Lock in Rake to a version compatible with rspec-rails 3.0
gem 'rake'

gem 'sass', require: 'sass'

group :test, :development do
  gem 'rspec-rails'
  gem 'pry'
end

group :test do
  gem 'webrick'
  gem 'factory_bot_rails', '~> 4.8.2'
  # https://github.com/thoughtbot/capybara-webkit/issues/1065
  gem 'capybara-webkit', github: 'thoughtbot/capybara-webkit', branch: 'master'
  gem 'capybara-screenshot'
  gem 'guard-rspec'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', require: false
  gem 'yarjuf'
  gem 'database_cleaner'
  gem 'rails-controller-testing'
end

gem 'capistrano',  '~> 3.1'
gem 'capistrano-rails', git: 'https://github.com/wearefine/rails'
gem 'capistrano-rvm'

gem 'mysql2'
gem 'pg'
gem "puma", "~> 5.0"

gem "fog-aws"
gem 'ddtrace', require: 'ddtrace/auto_instrument'
