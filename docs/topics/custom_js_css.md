# Custom JS, CSS and Helpers

* [Fae JS](#fae-js)
* [ES Modules and Stimulus](#es-modules-and-stimulus)
* [Fae CSS](#fae-css)
* [Custom Helpers](#custom-helpers)

---

Fae creates files in your app that allow custom JS and CSS in your admin.

## Fae JS

Your admin JavaScript lives in `app/javascript/fae_custom.js`, an ES module Fae loads on every admin page after its own scripts. Use it for plain jQuery customizations as well as Stimulus controllers (see [ES Modules and Stimulus](#es-modules-and-stimulus) for setup). jQuery and the `Fae` object are globals, and the DOM is parsed by the time the file runs, so you don't need `$(document).ready`.

Fae's legacy JavaScript initializes the page with `Fae.init(root)`. It runs on page load and again whenever markup is added after load (for example, the nested forms Fae loads over AJAX). After each run Fae dispatches a bubbling `fae:load` event on the root element, with the root in `event.detail.root`. Listen for it to set up your own widgets on new markup:

```JavaScript
// app/javascript/fae_custom.js
document.addEventListener("fae:load", (event) => {
  $(event.detail.root).find(".my-widget").myWidget()
})
```

`Fae.init` can run any number of times: elements and listeners that are already set up are skipped. Make your own handlers equally repeatable, either by binding delegated handlers once on `document`, or by guarding element-level setup (`Fae.fresh($(".my-widget"), "my-widget")` returns only the elements not yet marked for that key). If you inject markup yourself, call `Fae.init(element)` on it.

`app/assets/javascripts/fae.js` is no longer compiled into Fae's JavaScript. See the [upgrade notes](../upgrading/index.md) if you have one.

## ES Modules and Stimulus

Fae is gradually moving its admin UI from jQuery to [Stimulus](https://stimulus.hotwired.dev). New behaviour ships as ES modules loaded through an importmap that belongs to Fae (`Fae.importmap`), separate from your app's own `Rails.application.importmap`. It works whether or not your app uses importmaps, jsbundling, or nothing at all.

### Setup

Run the generator to add the files your app needs to extend Fae's modules:

```bash
rails g fae:importmap
```

This creates:

* `config/fae_importmap.rb`: pins added to Fae's importmap. It's drawn after Fae's own pins.
* `app/javascript/fae_custom.js`: your entry point, imported on every Fae admin page after Fae's own modules.
* `app/javascript/fae_custom/controllers/`: a home for your controllers.
* Two `link` lines in `app/assets/config/manifest.js` so Sprockets serves those files.

Restart your server after adding new pins.

### Registering your own controllers

`fae_custom.js` can import the Stimulus application Fae uses and register controllers on it:

```JavaScript
// app/javascript/fae_custom.js
import { application } from "fae"
import MapPickerController from "fae_custom/controllers/map_picker_controller"

application.register("map-picker", MapPickerController)
```

Controllers connect to matching `data-controller` elements, including markup added after page load (e.g. by Fae's AJAX nested forms).

### Fae's controllers

| Identifier | Attached to | Replaces |
|---|---|---|
| `fae-contrast` | `body` in `layouts/fae/application` | `Fae.contrast` |
| `fae-filtering` | forms rendered by `fae_filter_form` | `Fae.form.filtering` (pages with only pagination or `.js-sort-column` tables still use the legacy module) |
| `fae-language` | the language select in `fae/shared/_form_header` | `Fae.navigation.language` toggling and preference saving |

When a controller is attached, the legacy module it replaces doesn't run on that markup, so customizations made by redefining methods on the legacy object (e.g. in `fae_custom.js`) won't take effect there. Extend the controller instead.

### Extending or replacing Fae's controllers

Fae's controllers are registered with a `fae-` prefix (for example `fae-contrast`) and each one is pinned as its own module under `fae/controllers/`. Registering a controller with the same identifier replaces Fae's:

```JavaScript
import { application } from "fae"
import ContrastController from "fae/controllers/contrast_controller"

class CustomContrastController extends ContrastController {
  connect() {
    super.connect()
    // ...
  }
}

application.register("fae-contrast", CustomContrastController)
```

You can also swap out an entire Fae module by pinning the same name in `config/fae_importmap.rb`, or by adding a file with the same path (e.g. `app/javascript/fae/controllers/contrast_controller.js`). Prefer subclassing, since whole-file overrides are easy to break when you upgrade Fae.

### Third-party packages

Pin any packages your Fae modules need in `config/fae_importmap.rb`. Your app's own `config/importmap.rb` isn't loaded in the admin.

```ruby
pin 'sortablejs', to: 'https://cdn.jsdelivr.net/npm/sortablejs@1.15.2/+esm'
```

### Compression

Fae's modules use modern JavaScript syntax. If your app sets `config.assets.js_compressor = :uglifier`, switch to `:terser` (via the [terser](https://github.com/ahorek/terser-ruby) gem) or remove the compressor, since Uglifier can't parse ES modules.

## Fae CSS

Fae's admin stylesheet is prebuilt, so there's nothing to compile. Add your own admin styles to `app/assets/stylesheets/fae_custom.css` (or `fae_custom.scss` if your app compiles SCSS). The admin layouts link it after Fae's stylesheet, so your rules override Fae's. The install generator creates this file, and Fae adds it to the precompile list automatically.

To change the UI color, set the colorway in Fae's settings. It's exposed as the `--highlight-color` CSS custom property, which you can use in your own rules.

Fae's SCSS variables and mixins are not available in `fae_custom`.

## Custom Helpers

If you want to add your own helper methods for your Fae views, simply create and add them to `app/helpers/fae/fae_helper.rb`.

```ruby
module Fae
  module FaeHelper
    # ...
  end
end
```
