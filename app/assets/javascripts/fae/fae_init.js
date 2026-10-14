/* global Fae, FrobCoreHelpers, judge */

// This is a separate file to keep application.js pure
;(function() {
  // FCH dispatches the throttled window scroll, resize and load events to the modules that define those hooks
  window.FCH = new FrobCoreHelpers(Fae, {
    mobile_fps: false
  });

  /**
   * Initialize the admin UI inside `root`. Safe to call repeatedly: on page load, after AJAX has swapped in
   * new markup, and (with Turbo) after a render. Elements and listeners that are already set up are skipped.
   *
   * Dispatches a bubbling `fae:load` event on the root element when it's done, with `{ root }` as the detail.
   * Host JavaScript hooks in by listening for it (see docs/topics/custom_js_css.md).
   * @param {Element|jQuery|Document} [root=document]
   */
  Fae.init = function(root) {
    var $root = $(root || document);

    judge.enginePath = Fae.path + '/judge';

    if ($.trumbowyg) {
      $.trumbowyg.svgPath = Fae.config('trumbowyg-icons');
    }

    Fae.form.init($root);
    Fae.navigation.init($root);
    Fae.modals.init();
    Fae.tables.init();
    Fae.altTextManager.init();

    // FCH only dispatches `load` once, so catch up when initializing after the window has loaded
    if (document.readyState === 'complete') {
      Fae.navigation.load();
    }

    $root[0].dispatchEvent(new CustomEvent('fae:load', { bubbles: true, detail: { root: $root[0] } }));
  };

  // The scripts load in <head>, so the DOM isn't ready yet
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() { Fae.init(); });
  } else {
    Fae.init();
  }
})();
