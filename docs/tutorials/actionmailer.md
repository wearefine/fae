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

Be sure to update this each time your domain or subdomain changes.