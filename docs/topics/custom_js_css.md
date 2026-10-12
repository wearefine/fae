# Custom JS, CSS and Helpers

* [Fae JS](#fae-js)
* [ES Modules and Stimulus](#es-modules-and-stimulus)
* [Fae SCSS](#fae-scss)
* [Custom Helpers](#custom-helpers)

---

Fae creates two files in your assets pipeline that allow custom JS and CSS in your admin.

## Fae JS

`app/assets/javascripts/fae.js` compiles into `fae/application.js`. As noted in the file, you can use it as a mainfest (to add a lot of JS) or to simply add JS directly to.

#### Example: fae.js as a Manifest File

```JavaScript
// This file is compiled into fae/application.js
// use this as another manifest file if you have a lot of javascript to add
// or just add your javascript directly to this file
//
//= require admin/plugins
//= require admin/main
```

## ES Modules and Stimulus

Fae is gradually moving its admin UI from jQuery to [Stimulus](https://stimulus.hotwired.dev). New behaviour ships as ES modules loaded through an importmap that belongs to Fae (`Fae.importmap`), separate from your app's own `Rails.application.importmap`. It works whether or not your app uses importmaps, jsbundling, or nothing at all.

The legacy `fae.js` file above is still loaded, so existing customizations keep working.

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

## Fae SCSS

`app/assets/stylesheets/fae.scss` compiles into `fae/application.css`. Styles added to this files will be declared before other Fae styles.

## Custom Helpers

If you want to add your own helper methods for your Fae views, simply create and add them to `app/helpers/fae/fae_helper.rb`.

```ruby
module Fae
  module FaeHelper
    # ...
  end
end
```
