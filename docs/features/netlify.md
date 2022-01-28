# Netlify Deploy Monitor

* [Enabling Deploys](#enabling)
* [Upgrading](#upgrading)

---

## Enabling Deploys

`config/initializers/fae.rb`
```ruby
Fae.setup do |config|

  ## Netlify configs
  # Environment variables are recommended for any sensitive Netlify configuration details.
  config.netlify = {
    api_user: 'netlify-api-user',
    api_token: 'netlify-api-token',
    site: 'site-name-in-netlify',
    site_id: 'site-id-in-netlify',
    api_base: 'https://api.netlify.com/api/v1/'
  }

end
```
Two links have been added to the utility nav gear menu:
1. "Deploy Hooks" - for management of the Netlify build hook URLs.
2. "Deploy" - a page where deploys are executed, and status is monitored.

## Upgrading
After updating the FAE gem and bundling
1. `rake fae:install:migrations`
2. `rake db:migrate`

At this point you can now manage build hook URLs and execute/monitor deploys from the previously mentioned gear menu links.