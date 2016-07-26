appraise 'rails_4_1' do
  gem 'rails', '~> 4.1.0'
  gem 'remotipart'

  group :test, :development do
    gem 'quiet_assets'
  end

  group :test do
    gem 'capybara', '~> 2.4.1'
    gem 'capybara-webkit', '~> 1.8'
    gem 'database_cleaner', '~> 1.3.0'
  end
end

appraise 'rails_4_2' do
  gem 'rails', '~> 4.2.0'
  gem 'remotipart'

  group :test, :development do
    gem 'quiet_assets'
  end

  group :test do
    gem 'capybara', '~> 2.4.1'
    gem 'capybara-webkit', '~> 1.8'
    gem 'database_cleaner', '~> 1.3.0'
  end
end

appraise 'rails_5_0' do
  gem 'rails', '~> 5.0'
  gem 'remotipart', github: 'mshibuya/remotipart'

  group :test do
    gem 'rails-controller-testing'
    gem 'capybara', github: 'jnicklas/capybara'
    gem 'capybara-webkit'
    gem 'database_cleaner', '~> 1.5.0'
  end
end
