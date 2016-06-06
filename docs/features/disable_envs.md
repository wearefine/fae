# Disabling Environments

Sometimes an application will have two environments that share a DB. This is helpful when you want to flag data in a production admin to be available for review on a staging admin.

It can be confusing for the user to have an admin on the staging site and could potentially lead to unkowning affecting production data.

If you want to disable Fae on any Rails environment, you can do so with this option in `config/initializers/fae.rb`:

```ruby
Fae.setup do |config|

  config.disabled_environments = [ :preview, :staging ]

end
```