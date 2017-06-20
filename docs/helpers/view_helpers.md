# View Helpers

Fae provides a number of built in view helpers.

* [Fae Date Format](#fae-date-format)
* [Fae Datetime Format](#fae-datetime-format)
* [Fae Toggle](#fae-toggle)
* [Fae Clone Button](#fae-clone-button)
* [Fae Delete Button](#fae-delete-button)
* [Form Header](#form-header)
* [Require Locals](#require-locals)
* [Fae Avatar](#fae-avatar)
* [Fae Index Image](#fae-index-image)
* [Fae Sort ID](#fae-sort-id)
* [Fae Paginate](#fae-paginate)

---

## Fae Date Format

```ruby
fae_date_format
```

The fae_date_format and fae_datetime_format helpers format a DateTime object in Fae's preferred method.
The default fae_date_format formats to: 06/23/15.

```ruby
fae_date_format item.updated_at
```

## Fae Datetime Format

```ruby
fae_datetime_format
```

You can also use fae_datetime_format for the long date format with the timestamp: Jun 23, 2015  4:56pm PDT.

```ruby
fae_datetime_format item.updated_at
```

## Fae Toggle

```ruby
fae_toggle
```

![Fae toggle](https://raw.githubusercontent.com/wearefine/fae/master/docs/images/toggles.gif)

The fae_toggle helper method takes an AR object and attribute. It then creates the HTML necessary for a working Fae on/off toggle switch.

```ruby
fae_toggle item, :on_prod
```

## Fae Clone Button

```ruby
fae_clone_button
```

You can use `fae_clone_button` in your list view tables to provide easy access to clone an item. Just pass in the item and the button will clone the object and take you to the newly created object's edit form.

```ruby
fae_clone_button item
```

## Fae Delete Button

```ruby
fae_delete_button
```

You can use `fae_delete_button` in your list view tables to provide easy access to delete an item.

| option | type | description |
|---|---|---|
| item | ActiveRecord object | item to be deleted |
| delete_path (optional) | String | Route helper | delete endpoint |
| message (optional) | String | Custom alert message on delete
| attributes (optional) | symbol => value | pass custom attributes to the `link_to` helper |

```ruby
fae_delete_button item
```

```ruby
fae_delete_button item, "/#{fae_path}/delete", 'Destroy this item COMPLETELY' remote: true, data: { delete: 'true' }
```

## Form Header

```ruby
form_header
```

The form_header helper takes an AR object or string to render an `<h1>` based on the action. Can also display breadcrumb links.

| option | type | description |
|--------|------|-------------|
| header | ActiveRecord object | **(required)** passed to form_header helper method  |

**Examples**

```ruby
form_header @user
```
renders `Edit User` on the edit page

```ruby
form_header 'Release'
```
renders `New Release` on the new page

## Require Locals

```ruby
require_locals
```

The require_locals method is intended to be used at the beginning of any partial that pulls in a local variable from the page that renders it. It takes an Array of strings containing the variables that are required and the local_assigns view helper method.

If one of the locals aren't set when the partial is called, an error will be raised with an informative message.

```ruby
require_locals ['item', 'text'], local_assigns
```

## Fae Avatar

```ruby
fae_avatar
```

Retrieve a user's Gravatar image URL based on their email.

| option | type | description |
|---|---|---|
| user | Fae::User | defaults to `current_user` |

```ruby
fae_avatar(current_user)
#=> 'https://secure.gravatar.com/....'
```

## Fae Sort ID

```ruby
fae_sort_id
```

This method returns a string suitable for the row IDs on a sortable table. Note: you can make a table sortable by adding the `js-sort-row` class to it.

The parsed string is formatted as `"#{class_name}_#{item_id}"`, which the sort method digests and executes the sort logic.

```slim
tr id=fae_sort_id(item)
```

## Fae Index Image

```ruby
fae_index_image
```

This method returns a thumbnail image for display within table rows on index views. The image is wrapped by an `.image-mat` div, which is styled to ensure consistent widths & alignments of varied image sizes. If a `path` is provided, the image becomes a link to that location.

| option | type | description |
|---|---|---|
| image | Fae::Image | Fae image object to be displayed |
| path (optional) | String | A URL to be used to create a linked version of the image thumbnail |

```slim
/ With link
fae_index_image item.bottle_shot, edit_admin_release_path(item)
/#=> <div class='image-mat'><a href="..."><img src="..." /></a></div>

/ Without link
fae_index_image item.bottle_shot
/#=> <div class='image-mat'><img src="..." /></div>
```

## Fae Paginate

```slim
fae_paginate @items
```

![Fae paginate](https://raw.githubusercontent.com/wearefine/fae/master/docs/images/fae_paginate.png)

Adds pagination links for `@items`, given `@items` is an ActiveRecord collection.
