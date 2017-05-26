source "https://rubygems.org"

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
gem 'rails', '~> 5.1.0'

# Lock in Rake to a version compatible with rspec-rails 3.0
gem 'rake', '< 12.0.0'

gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 4.2.1'
gem 'sass', require: 'sass'
gem 'carrierwave', '~> 0.10.0'
gem 'rmagick', '~> 2.13.3', require: false

group :test, :development do
  gem 'rspec-rails', '~> 3.0.2'
  gem 'pry'
end

group :test do
  gem 'factory_girl_rails', '~> 4.4.1'
  gem 'capybara-webkit', '~> 1.11.1'
  gem 'capybara-screenshot'
  gem 'guard-rspec', '~> 4.3.1'
  gem 'selenium-webdriver', '~> 2.42.0'
  gem 'shoulda-matchers', require: false
  gem 'yarjuf'
  gem 'database_cleaner'
  gem 'rails-controller-testing'
end

gem 'capistrano',  '~> 3.1'
gem 'capistrano-rails', git: 'https://github.com/wearefine/rails'
gem 'capistrano-rvm'

gem 'mysql2'
