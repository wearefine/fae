# Caching within Fae

Fae internally caches a couple objects to help with performance. Before you can utilize this, you'll need to do a couple steps first.

## Setup

### 1. Enable caching in the parent app.

You'll need setup caching in the parent app as you normally would. This includes enabling `perform_caching` and setting a `cache_store` in your environment configs.

We're fans of memcached and the [Dalli gem](https://github.com/petergoldstein/dalli).

`config/environments/production.rb`
```ruby
config.action_controller.perform_caching = true
config.cache_store = :dalli_store, '127.0.0.1:11211', {
  expires_in: 1.day,
  compress: true
}
```

### 2. Enable caching in Fae

The second step is to enable Fae caching in Fae's initializer:

`config/initializers/fae.rb`
```ruby
config.use_cache = true
```

This flag only affects Fae's internal caching. This might seem redundant, but since Fae's caching may require manual cache busting (see below) we wanted developer's to manually enable just in case they setup cache for other reasons.

## Cache Keys and Busting

Once you enable Fae's caching it will start working immediately. You will have to be wary of what Fae caches and how to bust them accordingly. Here's a full list of cache keys used in Fae.

| Cache Key | Description | When to Bust |
|-----------|-------------|--------------|
| "fae_navigation_#{role_id}" | An instance of the `Fae::Navigation` for each role | Whenever any dynamic objects in the navigation change |
| fae_all_models | All non-Fae, non-excluded models | Whenever you deploy (busting you cache on deploy is recommended anyway) |

### Cache Busting Example

Say we list all people directly in our Fae navigation. If a person is added, edited or removed we'll need to bust all navigation caches so those changes are reflected.

To do this Fae provides a private method in the `Fae::BaseModelConcern` you can call `after_commit`.

`app/models/person.rb`
```ruby
class Person < ApplicationRecord
  include Fae::BaseModelConcern

  after_commit :fae_bust_navigation_caches
end
```

