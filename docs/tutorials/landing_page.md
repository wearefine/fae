# Overriding The Landing Page

If you want to ignore the default dashboard and make one of your views the landing page you can add a redirect route in your Fae namespace.

`config/routes.rb`
```ruby
# ...
namespace :admin do
  get '/', to: redirect('/admin/people')
  # ...
```
---