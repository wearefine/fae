# Migrating Fae's JavaScript to Stimulus

Fae's admin UI is moving from jQuery modules (`app/legacy_js/fae`, prebuilt into `app/assets/builds/fae_admin.js`) to [Stimulus](https://stimulus.hotwired.dev) controllers (`app/javascript/fae`, loaded through `Fae.importmap`). The two run side by side, so behaviour can be migrated one module at a time without rewriting Fae's Slim views.

* [Approach](#approach)
* [Adding a controller](#adding-a-controller)
* [Handing off from a legacy module](#handing-off-from-a-legacy-module)
* [Keeping legacy modules Turbo-safe](#keeping-legacy-modules-turbo-safe)
* [Working with jQuery plugins](#working-with-jquery-plugins)
* [Testing](#testing)
* [Turbo](#turbo)

## Approach

- Keep the existing Slim templates and Rails endpoints; add `data-controller` and friends to the markup that's already there.
- Each migrated behaviour has exactly one owner. When a controller takes over, the legacy module must stand down on that markup.
- Prefer native DOM APIs and `fetch` in new controllers. Keep thin bridges to jQuery only where a jQuery plugin (Chosen, jQuery UI) is still involved.
- Start with small, self-contained behaviours, then move on to the larger ones.

## Adding a controller

1. Create `app/javascript/fae/controllers/<name>_controller.js`. It's pinned automatically as `fae/controllers/<name>_controller`.
2. Import and register it in `app/javascript/fae/main.js` with a `fae-` prefixed identifier, e.g. `application.register("fae-language", LanguageController)`. Host apps rely on this prefix to [extend or replace Fae's controllers](../topics/custom_js_css.md#extending-or-replacing-faes-controllers).
3. Add the `data-controller` attribute in the view or helper that renders the markup.
4. List the controller in [Fae's controllers](../topics/custom_js_css.md#faes-controllers).

Avoid defining methods or getters that collide with Stimulus' `Controller` API (`application`, `context`, `element`, `identifier`, `scope`, `data`, `targets`, `outlets`, `classes`, `dispatch`). Overriding `scope`, for example, silently stops the controller from connecting.

## Handing off from a legacy module

Legacy modules initialize on DOM ready through the FCH ready queue, and Stimulus connects at about the same time, so the order between them isn't guaranteed. Have the legacy module check the markup instead:

```JavaScript
// handled by the fae-language Stimulus controller
if (this.el.$select.is('[data-controller~="fae-language"]')) {
  return;
}
```

This also keeps the legacy behaviour working for host apps that override the view and render the markup without the controller attribute.

Keep any public state other modules rely on (e.g. `Fae.navigation.language.el.$select`, used by `Fae.form.ajax`) assigned before the early return.

## Keeping legacy modules Turbo-safe

Fae's admin runs under Turbo Drive (it's opt-in for hosts, but the whole suite runs with it on, `rake spec:turbo`), and Drive replaces the `<body>` while the legacy scripts, `window` and `document` stay. When you touch a module in `app/legacy_js`:

* **Guard element setup** with `Fae.fresh($elements, 'key')`, and register one-time window, document and FCH listeners with `Fae.once('key', fn)` or a namespaced `$(document).off('.x').on('x.y', ...)`. `Fae.init` runs for every visit, AJAX swap and frame.
* **Never push to `FCH.scroll`, `FCH.resize` or `FCH.load` per element.** Register once and read the DOM when the listener fires (see `sticky.js`, which keeps a registry and drops detached elements).
* **Anything a third-party plugin binds to `window` or `document`** has to be released from the `turbo:before-render` handler in `fae_init.js` (see `destroyDateRangePickers` in `_dates.js`).
* **Don't cache jQuery objects of `body` or its descendants** across inits.
* `spec/features/turbo_lifecycle_spec.rb` fails if repeated visits grow the listeners on `window` and `document`, the FCH arrays or jQuery's data store. Run it after changing a module.

## Working with jQuery plugins

Chosen, the jQuery UI datepicker and calls like `$(form).submit()` fire events with jQuery's `.trigger()`, which native `addEventListener` listeners never receive. When a controller needs to hear them, bind through jQuery when it's present (jQuery handlers receive both triggered and genuine browser events) and fall back to native listeners:

```JavaScript
connect() {
  if (window.jQuery) {
    window.jQuery(this.element).on("change.faeLanguage", this.change)
  } else {
    this.element.addEventListener("change", this.change)
  }
}

disconnect() {
  if (window.jQuery) {
    window.jQuery(this.element).off(".faeLanguage")
  } else {
    this.element.removeEventListener("change", this.change)
  }
}
```

Don't bind both, or a native event will run the handler twice.

Always undo in `disconnect()` whatever `connect()` set up (document listeners, timers, plugin instances), so controllers are safe to reconnect once Turbo is in use.

## Testing

Add feature specs with `js: true` that wait for the controller to connect before interacting, and that prove the legacy module didn't also run. See `spec/features/stimulus_spec.rb` for examples.

## Turbo

Turbo isn't loaded yet. When it is, start with Turbo Drive disabled and opt pages in once their legacy JavaScript re-initializes correctly on `turbo:load`. Use Turbo Frames for bounded regions such as filtered index results.
