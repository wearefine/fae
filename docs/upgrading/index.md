# Upgrading Fae

* [To v2.2](#to-v22)
* [To v2.0](#to-v20)
* [To v1.5](#to-v15)
* [From v1.2 to v1.3](#from-v10-to-v11)
* [From v1.1 to v1.2](#from-v11-to-v12)

---

# To v2.2

* Introduction of the [Form Manager](../features/form_manager.md) and [Netlify](../features/netlify.md) integrations require installing and running new migrations
    1. run `rake fae:install:migrations`
    2. run `rake db:migrate`
* All instances of `= simple_form_for(['admin', @item]` have to be updated to `= simple_form_for([:admin, @item]`
    - This is required due to Rails no longer allowing strings to be passed to `polymorphic_url` to patch [this CVE](https://github.com/advisories/GHSA-hjg4-8q5f-x6fm)

# To v2.0

* Rails 4 support has been deprecated in v2, please upgrade to Rails 5+. Fae 1.7.x will continue to be supported for bug fixes you're staying on Rails 4.
* Many CSS classes produced by v1.2 generators have been deprecated and restructuring views may be necessary. If you have any of the following class names, please refer to the structure in `spec/dummy/app/views/admin/releases` or rescaffold your views to update.
    - main_table-sort_columns
    - main_content-sortable-handle
    - main_content-section-area
    - main_content-header
    - main_content-header-section-links
    - form_content-wrapper
* `Model#filter_all` has been deprecated. You can replace any calls to it with a custom method.
* `translate` has been renamed to `fae_translate`. Please refer to [the language documentation](../features/multi-language.md).
* The RMagick gem has been replaced by MiniMagick. Any custom methods in the uploaders not supported by MiniMagick will have to be updated.
* The `form_header` partial includes the errors previously rendered as a separate partial as well as the parent node markup (`header.content-header.js-content-header`). Please consolidate existing markup to use only the partial:
```slim
header.content-header.js-content-header
  = render 'fae/shared/form_header', header: @klass_name, f: f, item: @item
  = render 'fae/shared/errors'

/ to

= render 'fae/shared/form_header', header: @klass_name, f: f, item: @item
```
* The `language` option in the `form_header` parial has been renamed to `languages`.
* The `header` option in the `nested_table` partial has been deprecated
* `form_buttons` has been deprecated. Any admin still using this partial should remove `fae/shared/form_buttons` and only use [fae/shared/form_header](../helpers/partials.md#form-header). `form_header` still supports `save_button_text`, `cancel_button_text`, `cloneable`, and `cloneable_text` options.
* The `dark_hint` input option has been deprecated. Please convert all `dark_hint` calls to `hint`.
* `attr_toggle` has been deprecated. Use `fae_toggle` in its place.

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
