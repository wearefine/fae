# Upgrading Fae

* [To v3.0](#to-v30)
* [To v2.2](#to-v22)
* [To v2.0](#to-v20)
* [To v1.5](#to-v15)
* [From v1.2 to v1.3](#from-v10-to-v11)
* [From v1.1 to v1.2](#from-v11-to-v12)

---

# Unreleased

* Fae now requires Rails 8.0 or newer (and therefore Ruby 3.2+). It's tested on Rails 8.1 and Ruby 3.3.
    - Fae still uses the Sprockets asset pipeline. If your app uses Propshaft (the Rails 8 default), replace `gem "propshaft"` with `gem "sprockets-rails"` and add `app/assets/config/manifest.js`. See the [Quickstart Guide](../quickstart-guide.md). Fae raises an error on boot if Propshaft is loaded.
    - Fae adds its own JS to the precompile list, so `//= link fae/application.js` is no longer needed in your app's manifest (it's harmless to keep).
    - Upgrading pulls in new major versions of several of Fae's dependencies, including Devise 5, devise-two-factor 6, CarrierWave 3.1, MiniMagick 5 and Rack 3. Review their upgrade notes if your app customizes them.
    - Fae no longer depends on the deprecated Ruby `sass` gem or on `sass-rails`. If your app compiles its own SCSS, make sure `sass-rails` or `dartsass-rails` is in your `Gemfile`.
* Fae's admin stylesheet is now prebuilt (`fae_admin.css`, no longer `fae/application.css`) and no longer compiles a host `fae.scss`.
    - Remove `//= link fae/application.css` from `app/assets/config/manifest.js`. Sprockets raises an error for a missing linked file.
    - Move the contents of `app/assets/stylesheets/fae.scss` to `app/assets/stylesheets/fae_custom.css` (or `fae_custom.scss`), which is linked after Fae's stylesheet. Fae logs a warning at boot if `fae.scss` is still present. Fae's SCSS variables and mixins aren't available there, and `$c-custom-highlight` is gone. Set the colorway in Fae's settings instead, or use the `--highlight-color` CSS custom property.
    - If your app overrides Fae's layouts (`layouts/fae/application`, `layouts/devise` or `layouts/fae/error`), replace the `stylesheet_link_tag` for `fae/application` with `== render 'fae/application/stylesheet_tags'`.
    - Fae's SCSS sources moved from `app/assets/stylesheets/fae` to `app/stylesheets/fae`. Apps that `@import`ed them from their own stylesheets need to add that directory to their Sass load path.
* Activity log changes are now recorded when no Fae user is signed in (for example, changes made from the console, background jobs or seeds). Previously these were silently dropped in apps that require `belongs_to` associations by default.
* SVG uploads are no longer processed by ImageMagick for their `thumb` version. The thumb is a copy of the original, and Fae already displays SVGs at their original URL.
* Fae now loads ES modules and [Stimulus](https://stimulus.hotwired.dev) controllers through its own importmap, alongside the existing Sprockets bundle. No changes are required for existing `app/assets/javascripts/fae.js` customizations.
    - To add your own modules or controllers to the admin, run `rails g fae:importmap`. See [ES Modules and Stimulus](../topics/custom_js_css.md#es-modules-and-stimulus).
    - If your app sets `config.assets.js_compressor = :uglifier`, switch to `:terser` or remove it. Uglifier can't parse ES modules.
    - If your app overrides Fae's layouts (`layouts/fae/application` or `layouts/devise`), add `== render 'fae/application/importmap_tags'` after `javascript_include_tag 'fae/application'`, and add `data-controller="fae-contrast"` to the `body` tag of `layouts/fae/application`.
* The `Fae.contrast` JS object has been removed and replaced by the `fae-contrast` Stimulus controller.
* Filtering, sorting and paging on `fae_filter_form` pages, and the form header's language select, are now handled by the `fae-filtering` and `fae-language` Stimulus controllers. If your `fae.js` redefines methods on `Fae.form.filtering` or `Fae.navigation.language`, move those customizations to a [controller subclass](../topics/custom_js_css.md#extending-or-replacing-faes-controllers). If you override `fae/shared/_form_header`, add `data: { controller: 'fae-language', fae_language_preference_path_value: "/#{fae_path}/language_preference" }` to the language `select_tag` (without it, the legacy module keeps working).

# To v3.1

* Fae 3.1 has additions to the base schema which require installing and running new migrations
    1. run `rake fae:install:migrations`
    2. run `rake db:migrate`

# To v3.0

* Fae 3.0 has additions to the base schema which require installing and running new migrations
    1. run `rake fae:install:migrations`
    2. run `rake db:migrate`
* Fae 3.0 was built for Rails 7. Upgrading Fae on a previous version of Rails will require upgrading to Rails 7 as well.

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
