# Upgrading Fae

* [To v2.0](#to-v20)
* [To v1.5](#to-v15)
* [From v1.2 to v1.3](#from-v10-to-v11)
* [From v1.1 to v1.2](#from-v11-to-v12)

---

# To v2.0

* `form_buttons` has been deprecated. Any admin still using this partial should remove `fae/shared/form_buttons` and only use [fae/shared/form_header](docs/helpers/partials.md#form-header). `form_header` still supports `save_button_text`, `cancel_button_text`, `cloneable`, and `cloneable_text` options.
* The `dark_hint` input option has been deprecated. The dark hint style was removed in v1.3, but now [the option](docs/helpers/form_helpers.md#global-options) has been removed. Please convert all `dark_hint` calls to `hint`.
* The `form_header` partial includes the errors previously rendered as a separate partial as well as the parent node markup (`header.content-header.js-content-header`). Please consolidate existing markup to use only the partial:
```slim
header.content-header.js-content-header
  = render 'fae/shared/form_header', header: @klass_name, f: f, item: @item
  = render 'fae/shared/errors'

/ to

= render 'fae/shared/form_header', header: @klass_name, f: f, item: @item
```
* `attr_toggle` has been deprecated. Use `fae_toggle` in its place.
* Many CSS classes produced by v1.2 generators have been removed. It's easiest to re-scaffold your admin views entirely (chiefly `index.html.slim` and `_form.html.slim`, but also affecting `edit.html.slim` and `new.html.slim`). This CSS refactor also affects JavaScript; some features may break for admins that do not adopt the new CSS classes. Admins generated at or after v1.3 are unaffected.
* `translate` has been renamed to `fae_translate`. Please refer to [the language documentation](docs/features/multi-language.md).

# To v1.5

`has_top_nav` has been deprecated. Any admin still using side nav only will convert to using the top nav upon upgrade without any changes necessary.

# From v1.2 to v1.3

Fae v1.3 has a new layout featuring a horizontal navigation across the top of the app. After updating, you may chose to enable the top nav or not.

If you choose to enable top nav, you need to do the following:

In `config/initializers/fae.rb`, uncomment

```ruby
config.has_top_nav = true
```

You will also need to remove the existing `controllers/concerns/fae/nav_items` file, and add the new file to `models/concerns/fae/navigation_concern.rb`


### navigation_concern.rb file contents

```ruby
module Fae
  module NavigationConcern
    extend ActiveSupport::Concern

    # define the navigation structure in this file
    # navigation will default to the sidenav,
    # unless you set the following in the Fae initializer:
    #
    #   config.has_top_nav = true

    # example  structure with top nav:
    #
    # def structure
    #   [
    #     item('Top Nav Item 1', subitems: [
    #       item('Top Nav Dropdown Item 1', class: 'custom-class', path: some_named_route_path),
    #       item('Top Nav Dropdown Item 2', subitems: [
    #         item('Side Nav Item 1', subitems: [
    #           item('Side Nav Nested Item', path: some_named_route_path)
    #         ]),
    #         item('Side Nav Item 1', path: some_named_route_path)
    #       ]),
    #     ]),
    #     item('Pages', subitems: [
    #       item('Home', path: fae.edit_content_block_path('home')),
    #       item('About Us', path: fae.edit_content_block_path('about_us'))
    #     ])
    #   ]
    # end
  end
end
```

If you want the top level item for nav items with nested links to go to a specific path, pass in `path: some_named_route_path` to the top level after the name string, otherwise it will default to the first item in the list.

```ruby
# def structure
#   [
#     item('Top Nav Item 1', path: some_named_route_path, subitems: [
#       ...
```

# From v1.1 to v1.2

Fae v1.2 adds a new table `Fae::Change` to track changes on your objects. After updating you'll have to copy over and run the new migrations.

```bash
$ rake fae:install:migrations
$ rake db:migrate
```
