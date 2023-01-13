# Cloudflare Deploy Monitor

* [Enabling Deploys](#enabling-deploys)
* [Upgrading](#upgrading)

---

## Enabling Deploys

`config/initializers/fae.rb`
```ruby
Fae.setup do |config|

  ## Cloudflare configs
  # Environment variables are recommended for any sensitive Cloudflare configuration details.
  config.deploys_to = 'Cloudflare'
  config.cloudflare = {
    account_id: 'cloudflare-account-id',
    api_token: 'cloudflare-api-token',
    project_name: 'name-in-cloudflare',
    api_base: 'https://api.cloudflare.com/client/v4/'
  }

end
```

Two things added for this:
1. In the FAE options edit page, there is now a nested table to manage the deploy hooks.
2. A new link in the main nav, "Deploy" - a page where deploys are executed, and status is monitored.

## Upgrading
After updating the FAE gem and bundling
1. `rake fae:install:migrations`
2. `rake db:migrate`

At this point you can now manage build hook URLs and execute/monitor deploys from the previously mentioned gear menu links.