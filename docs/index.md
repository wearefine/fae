# Fae Installation and Customization

* [Installation](#installation)
* [Dependencies](#dependencies)
* [Installer](#faeinstall)
* [Seeding](#db-seed)
* [Versioning](#version-management)
* [Initializer](#fae-initializer)
* [Mailer Configuration](#devise-action-mailer-configuration)

---

# Installation

Add the gem to your Gemfile and run `bundle install`

```ruby
gem 'fae-rails'
```
Run the installer

```bash
$ rails g fae:install
```

After the installer completes, visit `/admin` and setup your first user account. That should automatically log you in to your blank Fae instance.

## Dependencies

### Rails

Fae supports Rails >= 4.1.

### Sass and sass-rails

Fae requires `sass >= 3.4` and `sass-rails >= 5`.

If you're using Rails 4.1 you'll need to update the versions in the `Gemfile`:

```ruby
gem 'sass-rails', '~> 5.0.0'
gem 'sass', '~> 3.4.0'
```

and run:

```bash
$ bundle update sass-rails
$ bundle update sass
```

## fae:install

Fae's installer will do the following:

- add Fae's namespace and route to `config/routes.rb`
- add `app/assets/stylesheets/fae.scss` for UI color management and custom CSS
- add `app/assets/javascripts/fae.js` for custom JS
- add `app/controllers/concerns/fae/nav_items.rb` to manage main navigation
- add Fae's initializer: `config/initializers/fae.rb`
- add `config/initializers/judge.rb` for validation config
- copies over migrations from Fae
- runs `rake db:migrate`
- seeds the DB with Fae defaults

## DB Seed

Fae comes with a rake task to seed the DB with defaults:

```bash
rake fae:seed_db RAILS_ENV=<your_env>
```

If you ran the installer, the task will be run automatically. But if you are setting up an established Fae instance locally or deploying to a server, running this will get you setup with some defaults.

## Version management

Fae follows semantic versioning, so you can expect the following format: `major.minor.patch`. Patch versions add bugfixes, minor versions add backwards compilable features and major versions add non-backward compatible features.

---

# Fae Initializer

Fae's default config can be overwritten in a `config/initializers/fae.rb` file.

| key | type | default | description |
| --- | ---- | ------- | ----------- |
| devise_secret_key | string | | unique Devise hash |
| devise_mailer_sender | string | change-me@example.com | address used to send Devise notifications (i.e. forgot password emails) |
| dashboard_exclusions  | array | [] | array of models to hide in the dashboard |
| max_image_upload_size | integer | 2 | ceiling for image uploads in MB |
| max_file_upload_size | integer | 5 | ceiling for file uploads in MB |
| recreate_versions | boolean | false | Triggers `Fae::Image` to recreate Carrierwave versions after save. This is helpful when you have conditional versions that rely on attributes of `Fae::Image` by making sure they're saved before versions are created. |
| track_changes | boolean | true | Determines whether or not to track changes on your objects |
| tracker_history_length | integer | 15 | Determines the max number of changes logged per object |

### Example

```ruby
Fae.setup do |config|

  config.devise_secret_key = '79a3e96fecbdd893853495ff502cd387e22c9049fd30ff691115b8a0b074505be4edef6139e4be1a0a9ff407442224dbe99d94986e2abd64fd0aa01153f5be0d'

  # models to exclude from dashboard list
  config.dashboard_exclusions = %w( Varietal )

end
```

---

# Devise Action Mailer Configuration

In order for Fae's password reset email function to work you need to make sure you application can send mail and set a default url option for ActionMailer in each `config/environments/*env.rb` file.

## Example

```ruby
Rails.application.configure do
  # development.rb
  config.action_mailer.default_url_options = { host: 'localhost:3000' }
  # remote_development.rb
  config.action_mailer.default_url_options = { host: 'dev.yoursite.com' }
  # stage.rb
  config.action_mailer.default_url_options = { host: 'stage.yoursite.com' }
  # production.rb
  config.action_mailer.default_url_options = { host: 'yoursite.com' }
end
```
