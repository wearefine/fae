# Netlify Deploy Monitor

* [Enabling Deploys](#enabling-deploys)
* [Email Notifications](#email-notifications)

Fae provides an easy integration for statically generated frontends hosted on Netlify. If Fae is delivering content to a statically generated frontend via JSON or GraphQL APIs, updating content in the admin won't trigger a build of the frontend with the new content.

This feature allows a super admin to define multiple deploy environments connected to Netlify deploy hooks. It also establishes a global deploy page so admin and super admin users can trigger builds of any defined Netlify environments.

The deploy page will also display the status of the current deploy, along with a list of past deploys.

---

## Enabling Deploys

In your app, run `rake fae:install:migrations` and then migrate the database.

To enable this feature, make sure `config.netlify` is defined in your Fae initializer with all options set correctly.

`notification_hook_signature` is only required if you will use incoming Netlify deploy notification webhooks.

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
    api_base: 'https://api.netlify.com/api/v1/',
    notification_hook_signature: 'netlify-notification-hook-signature'
  }

end
```

Then go to the root settings at `/admin/root` while logged in as a super admin and add deploy hooks for each environment you wish to enable in the CMS.

You will see a new nav item labeled "Deploy" that links to `/admin/deploy`. Here you'll be able to trigger and view past deploys.

---

## Email Notifications

In your app, run `rake fae:install:migrations` and then migrate the database.

You can opt-in to email-based notifications for when Netlify deploys complete successfully or fail.

The migration adds a new field to the `Fae::User` model and accompanying checkbox in the user form - `receive_deploy_notifications`, pretty self-explanatory. Any users opted in to this setting will receive the email notifications.

In the https://app.netlify.com dashboard for your project, you'll need to add two new webhook notifications - one for `Deploy succeeded` and `Deploy failed`. Both of these webhooks will point to the same URL: https://your-fae-domain.com/admin/netlify_hooks/netlify_hook (replace your-fae-domain with a real value). Your `JWS secret token` can be any string, but it needs to also be set to, and match what you set it to in the `fae.rb` file's `config.netlify['notification_hook_signature']`.