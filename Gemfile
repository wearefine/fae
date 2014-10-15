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

gem 'rspec-rails', '~> 3.0.2', group: [:test, :development]

gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 4.2.1'
gem 'remotipart'
gem 'carrierwave', '~> 0.10.0'
gem 'rmagick', '~> 2.13.3', require: false
gem 'judge', '~> 2.0.4'
gem 'judge-simple_form', '~> 0.4.0'

group :test do
  gem 'factory_girl_rails', '~> 4.4.1'
  gem 'capybara', '~> 2.4.1'
  gem 'capybara-webkit', '~> 1.1.0'
  gem 'capybara-screenshot'
  gem 'guard-rspec', '~> 4.3.1'
  gem 'database_cleaner', '~> 1.3.0'
  gem 'selenium-webdriver', '~> 2.42.0'
end

gem 'capistrano',  '~> 3.1'
# gem 'capistrano-rails', path: '/Library/WebServer/Documents/work/open_source/capistrano-rails'
gem 'capistrano-rails', git: 'https://github.com/jamesmkur/rails.git'
gem 'capistrano-rvm'

gem 'mysql2'