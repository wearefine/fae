# Frontend Overrides (Inertia/Vue)

Fae v5 supports host-level frontend overrides without forking the engine.

There are two override levels:

* Page override: replace one full Inertia page.
* Component override: replace one shared Vue component globally.

## How It Works

The host entrypoint calls `createFaeApp` and can pass two optional globs:

* `pages`: host page modules that override engine pages by name.
* `components`: host component modules that override engine components by name.

```js
// app/frontend/entrypoints/fae.js (host app)
import { createFaeApp } from '@fae/index.js'

createFaeApp({
  pages: import.meta.glob('../pages/**/*.vue'),
  components: import.meta.glob('../components/**/*.vue'),
})
```

## Page Override Example

If Fae renders the page `Fae/Index`, the host can override it by adding:

`app/frontend/pages/Fae/Index.vue`

No controller changes are needed when the page name is the same.

## Component Override Example

To override the shared form field renderer globally, add:

`app/frontend/components/FaeFormField.vue`

That replacement will be used anywhere the engine resolves `FaeFormField`
through the override seam (including top-level and nested forms).

## Name Matching Rules

Component override keys are derived from the file path under
`components/`.

Examples:

* `app/frontend/components/FaeFormField.vue` -> `FaeFormField`
* `app/frontend/components/FaeIndexTable.vue` -> `FaeIndexTable`
* `app/frontend/components/forms/FancySelect.vue` -> `forms/FancySelect`

The host file must match the same component key expected by the engine.

## Direct Map Alternative

If you do not want to use a glob, pass explicit components:

```js
import { createFaeApp } from '@fae/index.js'
import MyFormField from '../components/FaeFormField.vue'

createFaeApp({
  pages: import.meta.glob('../pages/**/*.vue'),
  components: {
    FaeFormField: MyFormField,
  },
})
```

## Recommended Strategy

* Prefer component overrides for small UI behavior/style changes.
* Use page overrides when the screen structure changes materially.
* Keep component API compatibility with the engine props/events to reduce
  upgrade friction.

## Single-Resource Override Patterns

Yes. A host app can override just one resource view.

### Inertia page for one resource

If a single resource uses a specific page name, override only that page file.

Controller:

```ruby
# app/controllers/admin/beers_controller.rb
def index
  render inertia: 'Admin/BeersIndex', props: {
    # ...
  }
end
```

Host override file:

`app/frontend/pages/Admin/BeersIndex.vue`

Only that resource page is replaced; other resources continue using engine
pages.

### Complete example (working in dummy app)

Controller (`spec/dummy/app/controllers/admin/beers_controller.rb`):

```ruby
module Admin
  class BeersController < Fae::BaseController
    include Fae::InertiaRenderable

    def index
      render inertia: 'Admin/BeersIndex', props: {
        title: @klass_humanized.pluralize.titleize,
        newPath: @new_path,
        newButtonText: t('fae.common.add', title: @klass_humanized.titleize),
        rows: @klass.for_fae_index.map { |item| beer_index_row(item) }
      }
    end
  end
end
```

Matching host page file (`spec/dummy/app/frontend/pages/Admin/BeersIndex.vue`):

```vue
<template>
  <div>
    <div class="fae-page-header">
      <div class="fae-page-header__title">
        <h1>{{ title }}</h1>
      </div>
    </div>

    <div class="fae-table-wrap">
      <table class="fae-table">
        <!-- resource-specific table UI -->
      </table>
    </div>
  </div>
</template>
```

Host entrypoint must include pages glob (`spec/dummy/app/frontend/entrypoints/fae.js`):

```js
createFaeApp({
  pages: import.meta.glob('../pages/**/*.vue'),
})
```

With that setup, only `Admin/BeersIndex` is overridden.

### Generic page but one resource-specific behavior

If many resources use `Fae/Form` or `Fae/Index`, prefer a component override
plus a per-field or per-resource flag from the controller (for example a field
option) rather than replacing the whole generic page.

### Legacy Slim/ERB view for one resource

For non-Inertia views, standard Rails view lookup applies. Add a matching host
template path for that resource and Rails will pick it before the engine copy.

Example:

`app/views/admin/articles/_form.html.slim`
