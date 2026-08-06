# Theming

Fae supports user-level admin theming with a shared highlight system.

## Overview

Theme is selected per user and persisted to `fae_users.theme`.

Supported values:

* `light`
* `dark`
* `indigo`
* `darkstar`

Base mode and highlight color are resolved from that selection:

* `light`: light base palette + root setting colorway highlight
* `dark`: dark base palette + root setting colorway highlight
* `indigo`: light base palette + `#4B0082` highlight
* `darkstar`: dark base palette + `#ed0c0c` highlight

## Data Model

Migration adds the column:

```ruby
add_column :fae_users, :theme, :string, null: false, default: 'light'
```

Model behavior lives in `Fae::User` and includes:

* inclusion validation for supported themes
* default assignment
* helper methods for mode and highlight resolution

## Runtime Flow (Inertia)

1. Shared props compute effective theme values.
2. The HTML layout renders initial mode/highlight for first paint.
3. Vue layouts re-apply mode/highlight from page props on navigation.
4. CSS semantic tokens consume those values across components.

Shared props include:

* `name`
* `mode`
* `highlightColor`
* `defaultHighlightColor`

## First Paint

The Inertia layout sets initial `data-fae-theme` and `--fae-highlight` server-side so the page does not flash an incorrect theme while JS boots.

## Live Preview In User Settings

In the user settings form, selecting a theme applies immediate preview in the browser before save.

Saving the form persists the selection to the user record.

## Files To Know

* `db/migrate/20260805120000_add_theme_to_fae_users.rb`
* `app/models/fae/user.rb`
* `app/controllers/concerns/fae/inertia_shared_props.rb`
* `app/views/layouts/fae/inertia.html.erb`
* `app/frontend/layouts/FaeLayout.vue`
* `app/frontend/layouts/FaeAuthLayout.vue`
* `app/frontend/pages/Fae/Form.vue`
* `app/frontend/styles/tokens.css`
