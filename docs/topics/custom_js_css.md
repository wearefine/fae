# Custom JS, CSS and Helpers

* [Fae JS](#fae-js)
* [ES Modules and Stimulus](#es-modules-and-stimulus)
* [Turbo](#turbo)
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
| `fae-cancel` | the Cancel button in the form header, options and site forms | `Fae.form.cancel` (the legacy module still runs on overridden markup without the controller) |
| `fae-contrast` | `body` in `layouts/fae/application` | `Fae.contrast` |
| `fae-deploy` | `main.content` on the deploy page | `Fae.deploy` |
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

## Turbo

Fae loads [Turbo](https://turbo.hotwired.dev) in the admin, from the same importmap as Stimulus, so `window.Turbo` is available to your `fae_custom.js`. **Turbo Drive is off by default**: links and forms behave exactly as before and every navigation is a full page load.

To try Drive, either turn it on for the whole admin in `config/initializers/fae.rb`:

```ruby
Fae.setup do |config|
  config.turbo_drive = true
end
```

or leave it off and opt a page or region in by adding `data-turbo="true"` to an element (everything inside it is driven). Fae's own admin pages are tested with Drive on (the whole suite runs both ways), but your customizations may not be Drive-safe yet, which is why it's off by default.

### What Drive changes

With Drive on, a link click or form submission becomes a `fetch` and only the `<body>` is swapped. The page's `<head>`, window, document and every script loaded in the head, including Fae's, stay alive. Fae's JavaScript takes care of this for you: it initializes each new body, releases what the old one held, and keeps window and document listeners from piling up.

* Forms that pass Fae's validator are submitted with `requestSubmit()`, so Turbo handles them. A failed save re-renders in place (`422`), and a successful one redirects (`303`) with the flash shown on the next page.
* `remote: true` forms and `data-method` / `data-confirm` links are still handled by jquery_ujs, once. Turbo skips events jquery_ujs has handled, so they work the same under Drive. Links with `data-method` still do a full page load.
* Draft forms ask before a Turbo visit leaves them, the same way they warn before the tab closes.
* Admin pages are excluded from Turbo's snapshot cache (`turbo-cache-control: no-cache`), and Fae's script and stylesheet tags carry `data-turbo-track="reload"`, so a deploy of new assets reloads the page.
* Turbo Frames and Streams aren't used by Fae's pages yet. Content inside a `<turbo-frame>` is initialized when it loads (`turbo:frame-load`).

### Writing Turbo-safe JavaScript

`fae_custom.js` is a module, so it runs **once** per full page load, not once per visit. Put one-time setup there and per-page setup in a `fae:load` listener. Fae dispatches `fae:load` on `document` after every page load and Turbo visit, and on the root element when it initializes AJAX-loaded markup or a frame (`event.detail.root`).

```JavaScript
// app/javascript/fae_custom.js

// Once: document-level handlers survive every visit, so bind them here, on `document`
$(document).on("click", ".js-my-toggle", function () { /* ... */ })

// Per page: runs for the initial load, each Turbo visit and AJAX-loaded content
document.addEventListener("fae:load", (event) => {
  Fae.fresh($(event.detail.root).find(".my-widget"), "my-widget").myWidget()
})
```

The rules:

* **Never bind on `body` or on elements that a visit replaces** and expect it to survive; bind delegated handlers on `document`, or bind to elements inside a `fae:load` listener (the elements are new on every visit).
* **Guard element setup with `Fae.fresh($elements, "key")`**, which returns only the elements not yet initialized for that key. `fae:load` can fire more than once for the same element.
* **Release what you attach outside the page.** Anything bound to `window` or `document` from a per-page setup, plugins that do it internally (like a date picker), timers and observers must be removed when the page goes away. Listen for `turbo:before-render`, or use a Stimulus controller and its `disconnect()`, which Stimulus calls for you.
* **Prefer Stimulus controllers for new behaviour.** They connect and disconnect with the markup, so none of the above applies.
* **A form your own JavaScript submits** (for example with `fetch` or `$.ajax`) and that doesn't call `preventDefault()` needs `data-turbo="false"`, or Drive will submit it as well.

## Fae CSS

Fae's admin stylesheet is prebuilt, so there's nothing to compile. Add your own admin styles to `app/assets/stylesheets/fae_custom.css` (or build it into `app/assets/builds/fae_custom.css` from `fae_custom.scss` with a Sass builder such as `dartsass-rails`). The admin layouts link it after Fae's stylesheet, so your rules override Fae's. The install generator creates this file.

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
