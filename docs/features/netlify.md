# Netlify Deploy Monitor

* [Enabling Deploys](#enabling-deploys)
* [Upgrading](#upgrading)

Fae provides and easy integration for statically generated frontends hosted on Netlify. If Fae is delivering content to a statically generated frontend via JSON or GraphQL APIs, updating content in the admin won't trigger a build of the frontend with the new content.

This feature allows a super admin to define multiple deploy environments connected to Netlify deploy hooks. It also establishes a global deploy page so admin and super admin users can trigger builds of any defined Netlify environments.

The deploy page will also display the status of the current deploy, along with a list of past deploys.

---

## Enabling Deploys

To enable this feature, make sure `config.netlify` is defined in your Fae initializer with all options set correctly.

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

Then go to the root settings at `/admin/root` while logged in as a super admin and add deploy hooks for each environment you wish to enable in the CMS.

You will see a new nav item labeled "Deploy" that links to `/admin/deploy`. Here you'll be able to trigger and view past deploys.
