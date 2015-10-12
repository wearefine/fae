# Cloning

[TOC]

---

So you want to easily, automagically clone a record and its children? Lucky for you, we made it easy to do that! You're welcome.

# Basic

The most basic implementation of this feature clones the record, all it's attributes (except id, created and updated at) and any belongs_to associations via foreign_keys. We also check for any uniqueness validators on your attributes and rename them to "attribute-#", starting at 2, for your convenience.

## Add a route

Inside your admin namespace, and the resource you wish to be cloneable, add the `create_from_existing` action.

**Example**

```ruby
namespace :admin do
  resources :releases do
    get 'create_from_existing', on: :member
  end
end
```

## Add Buttons

You may add the clone button to the index, edit form, or both.

**Examples**

#### For Index

Add the following to your `thead`, usually after 'Delete':

```slim
  th class="main_table-header-clone" data-sorter="false" Clone
```

And to your `tbody`:

```slim
td class="main_table-clone"
  = link_to create_from_existing_admin_release_path(item), class: 'main_table-action' do
    span class="icon-users"
```

#### For Form

Simply pass `cloneable: true` into your form_buttons partial. You may also edit the default text 'Clone', by passing in `clone_button_text` and your own string.

```ruby
  render 'fae/shared/form_buttons', cloneable: true, clone_button_text: 'Duplicate Me!'
```

That's all for basic set-up.

# Advanced

If you want complete control over which attributes and associations are cloned, we wouldn't call you a control freak. We've baked in some nice simple methods to make this possible.

## Whitelisting Attributes

If you want to whitelist attributes to be cloned, you may add the `attributes_for_cloning` method into your controller's private method. Just pass in an array of symbols and we will take care to only copy those attributes over.

**Note:** please make sure to include _everything_ that is required, or the record will fail to get created. You've been warned.

**Example**

```ruby
def attributes_for_cloning
  [:name, :slug, :description, :wine_id]
end
```

## Cloning Associations

Belongs_to associations are automatically copied over, unless you are whitelisting attributes and forget to/ purposely don't add it there. For the rest of the associations you may have (i.e. has_one, has_many, has_and_belongs_to_many, has_many_through), you may use the `associations_for_cloning` method by passing in array of symbols.

**Note:** Any images or files you have will be copied along, if you have included those relationships.

**Example**

```ruby
def associations_for_cloning
  [:aromas, :events]
end
```

That's it! Happy cloning. :)
