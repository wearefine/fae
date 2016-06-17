# Authorization

Fae comes with three user roles with three different authorization levels by default.

- super admin: CRUD all objects, INCLUDING users and root settings
- admin: CRUD all objects, INCLUDING users and EXCLUDING root settings
- user: CRUD all objects, EXCLUDING users and root settings

If you want to use these roles to limit access to certain objects you can by updating `Fae::AuthorizationConcern`

## Authorization Concern

The Authorization Concern is generated when you install Fae and can be found at `app/models/concerns/fae/authorization_concern.rb`.

If you don' t have this file, you probably installed Fae before the feature was added. Update Fae and copy [this file](../../blob/master/lib/generators/fae/templates/models/concerns/authorization_concern.rb) to the location above to get started.

### Access Map

The only thing within `Fae::AuthorizationConcern` you'll need to touch is the `access_map`. The `access_map` is a hash of authorization definitions, each formatted like this:

```ruby
plural_controller_name => array_of_roles
```

| `plural_controller_name` | a string of the plural controller name referencing the object |
| `array_of_roles` | an array of stringed role names with access to object |

The `access_map` will only be able to manage authorization on objects created in the parent app.

#### Authorizing Content Blocks

To limit content blocks (or pages), use `"content_blocks/#{page_name}"` as the format for the `plural_controller_name`.

#### Example

```ruby
module Fae
  module AuthorizationConcern
    extend ActiveSupport::Concern
    module ClassMethods

      def access_map
        {
          'people' => ['super admin'],
          'locations' => ['super admin', 'admin'],
          'content_blocks/homepage' => ['super admin', 'admin', 'custom role']
          'content_blocks/about_us' => ['super admin', 'admin', 'custom role']
        }
      end

    end
  end
end
```

## Custom Roles

You can define a new `Fae::Role` by creating it in the console:

```ruby
Fae::Role.create(name: 'asset manager')
```

Custom roles will have the same permissions as Fae's user role and they won't be able to inherit any higher access levels.

Once the new role has been created, you'll be able to define the role in the `access_map` and assign the role to admin users.

